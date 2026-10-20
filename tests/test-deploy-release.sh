#!/usr/bin/env bash
# Tests of scripts/deploy-release.sh (MIL-021 task 6, ADR-0010, ADR-0012 of NFHotel): the
# argument checks, a deploy, a failed smoke test with an automatic rollback, a manual
# rollback, the lock, and the refusal of a VM whose /opt/nfhotel is not a checkout of
# NF-Hotel/DevOps. Fakes stand in for deploy-services.sh and curl, so no container runs.
#
# Run it in Debian 12 with the repository at /src:
#   docker run --rm -v "$PWD:/src:ro" debian:12-slim bash /src/tests/test-deploy-release.sh
# Exit:  0 every check passed; 1 a check failed
# Needs: Debian 12 (apt-get, git, flock)

# shellcheck disable=SC2015 # ok and ko always return 0, so `test && ok || ko` runs
# exactly one of them; the short form keeps each check on one line.
set -uo pipefail

apt-get -qq update >/dev/null && apt-get -qq install -y git >/dev/null 2>&1
git config --global user.email test@example.com
git config --global user.name test
git config --global init.defaultBranch main

W="$(mktemp -d)"
trap 'rm -rf "$W"' EXIT
pass=0
fail=0
ok() {
  echo "PASS  $1"
  pass=$((pass + 1))
}
ko() {
  echo "FAIL  $1"
  fail=$((fail + 1))
}

# A DevOps repository with two commits; the VM checkout points at its GitHub URL, which
# git rewrites to the local copy (the script checks the configured URL).
git init -q --bare "$W/origin.git"
git -C "$W/origin.git" config uploadpack.allowAnySHA1InWant true
git clone -q "$W/origin.git" "$W/src" 2>/dev/null
mkdir -p "$W/src/scripts" "$W/src/deploy/nginx" "$W/bin"
cat >"$W/src/scripts/deploy-services.sh" <<EOF
echo "web=\$NFHOTEL_WEB_IMAGE" >>"$W/calls"
if [[ "\$NFHOTEL_WEB_IMAGE" == *bbbbbbbb* ]]; then echo bad >"$W/health"; else echo good >"$W/health"; fi
EOF
git -C "$W/src" add -A && git -C "$W/src" commit -qm a
A="$(git -C "$W/src" rev-parse HEAD)"
echo 1 >"$W/src/x" && git -C "$W/src" add -A && git -C "$W/src" commit -qm b
B="$(git -C "$W/src" rev-parse HEAD)"
git -C "$W/src" push -q origin main
git clone -q "$W/origin.git" "$W/app"
git config --global url."$W/origin.git".insteadOf https://github.com/NF-Hotel/DevOps.git
git -C "$W/app" remote set-url origin https://github.com/NF-Hotel/DevOps.git
git clone -q "$W/origin.git" "$W/other" && git -C "$W/other" remote set-url origin https://github.com/NF-Hotel/NFHotel.git
mkdir -p "$W/legacy/deployment" && echo "services: {}" >"$W/legacy/deployment/compose.yaml"
cat >"$W/bin/curl" <<EOF
#!/bin/bash
[[ "\$(cat $W/health)" == good ]] || { echo 502; exit 0; }
for a in "\$@"; do case "\$a" in http://*) echo 301; exit 0 ;; https://*) echo 200; exit 0 ;; esac; done
EOF
chmod +x "$W/bin/curl"

APP="$(printf 'c%.0s' $(seq 40))"
D="sha256:$(printf 'a%.0s' $(seq 64))"
BAD="sha256:$(printf 'b%.0s' $(seq 64))"
R=ghcr.io/nf-hotel
good() { echo "$APP $1 $R/nfhotel-web@$D $R/nfhotel-api@$D $R/market-analysis@$D $R/benchmark@$D"; }
bad() { echo "$APP $1 $R/nfhotel-web@$BAD $R/nfhotel-api@$D $R/market-analysis@$D $R/benchmark@$D"; }
run() {
  local dir="$1"
  shift
  PATH="$W/bin:$PATH" NFHOTEL_USER=root NFHOTEL_STATE="$W/state-$(basename "$dir")" NFHOTEL_DIR="$dir" \
    bash /src/scripts/deploy-release.sh "$@" >"$W/out" 2>&1
}
expect_code() {
  local want="$1" desc="$2"
  shift 2
  run "$W/app" "$@"
  local got=$?
  if [[ "$got" == "$want" ]]; then ok "$desc"; else ko "$desc (exit $got, wanted $want: $(head -1 "$W/out"))"; fi
}

# shellcheck disable=SC2046 # the release fields are split on purpose
{
  expect_code 2 "refuses a short NFHotel commit" deploy abc "$A" "$R/nfhotel-web@$D" "$R/nfhotel-api@$D" "$R/market-analysis@$D" "$R/benchmark@$D"
  expect_code 2 "refuses a short DevOps commit" deploy "$APP" main "$R/nfhotel-web@$D" "$R/nfhotel-api@$D" "$R/market-analysis@$D" "$R/benchmark@$D"
  expect_code 2 "refuses the images in the wrong order" deploy "$APP" "$A" "$R/nfhotel-api@$D" "$R/nfhotel-web@$D" "$R/market-analysis@$D" "$R/benchmark@$D"
  expect_code 2 "refuses shell text in a digest" deploy "$APP" "$A" "$R/nfhotel-web@$D;id" "$R/nfhotel-api@$D" "$R/market-analysis@$D" "$R/benchmark@$D"
  expect_code 2 "refuses another registry" deploy "$APP" "$A" "evil.io/nf-hotel/nfhotel-web@$D" "$R/nfhotel-api@$D" "$R/market-analysis@$D" "$R/benchmark@$D"
  expect_code 2 "refuses a dot used as a wildcard" deploy "$APP" "$A" "ghcrXio/nf-hotel/nfhotel-web@$D" "$R/nfhotel-api@$D" "$R/market-analysis@$D" "$R/benchmark@$D"
  expect_code 2 "refuses three digests" deploy "$APP" "$A" "$R/nfhotel-web@$D" "$R/nfhotel-api@$D" "$R/market-analysis@$D"
  expect_code 2 "refuses an unknown command" install

  expect_code 0 "deploys release A" deploy $(good "$A")
  [[ "$(git -C "$W/app" rev-parse HEAD)" == "$A" ]] && ok "the VM is at DevOps commit A" || ko "HEAD after A"
  expect_code 1 "a failed smoke test fails the deploy of B" deploy $(bad "$B")
  grep -q "rolled back to $APP" "$W/out" && [[ "$(git -C "$W/app" rev-parse HEAD)" == "$A" ]] &&
    [[ "$(cat "$W/health")" == good ]] && ok "it rolled back to release A" || ko "rollback after failed B"
  expect_code 0 "deploys release B" deploy $(good "$B")
  [[ "$(wc -l <"$W/state-app/releases.log")" == 2 ]] && ok "the release log holds two releases" || ko "release log"
  awk 'NF == 7' "$W/state-app/releases.log" | grep -q "$APP $B" && ok "the log records both commits" || ko "log fields"
  expect_code 0 "rolls back by hand" rollback
  [[ "$(git -C "$W/app" rev-parse HEAD)" == "$A" ]] && ok "the manual rollback restored A" || ko "manual rollback"
}

(
  exec 9>"$W/state-app/lock"
  flock 9
  sleep 3
) &
sleep 1
expect_code 1 "refuses a second deploy while one runs" status
wait

# shellcheck disable=SC2046
{
  run "$W/legacy" deploy $(good "$A")
  [[ $? == 1 ]] && grep -q "not a git checkout" "$W/out" && [[ -f "$W/legacy/deployment/compose.yaml" ]] &&
    ok "refuses a VM without a DevOps checkout and leaves it untouched" || ko "legacy layout: $(head -1 "$W/out")"
  run "$W/other" deploy $(good "$A")
  [[ $? == 1 ]] && grep -q "not of NF-Hotel/DevOps" "$W/out" && ok "refuses a checkout of another repository" ||
    ko "other repository: $(head -1 "$W/out")"
}

echo "RESULT: $pass passed, $fail failed"
((fail == 0))
