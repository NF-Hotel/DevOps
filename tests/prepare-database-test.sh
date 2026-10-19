#!/usr/bin/env bash
# Prepare the inputs of tests/test-database.sh from an NF-Hotel/NFHotel checkout: the
# idempotent EF Core migration script and the API image (MIL-024 task 6). Used by the CI of
# this repository; it builds locally and pushes nothing.
#
# Usage: prepare-database-test.sh <NFHotel checkout> <output folder>
#   writes <output folder>/migrations.sql and builds the image nfhotel-api:test
# Exit:  0 prepared; 1 a step failed; 2 usage error
# Needs: bash 4+, the .NET SDK of the checkout's global.json, docker

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/common.sh
. "$ROOT/scripts/lib/common.sh"
readonly EF_VERSION=10.0.13

[[ $# == 2 && -f "$1/Dockerfile.api" ]] || {
  usage >&2
  exit 2
}
app="$(cd "$1" && pwd)"
mkdir -p "$2"
out="$(cd "$2" && pwd)"

echo "==> dotnet-ef $EF_VERSION"
dotnet tool update --global dotnet-ef --version "$EF_VERSION" >/dev/null || die "cannot install dotnet-ef"
export PATH="$PATH:$HOME/.dotnet/tools"

echo "==> the idempotent migration script"
(cd "$app" && dotnet restore src/NFHotel.Infrastructure >/dev/null) || die "restore failed"
# The design-time factory needs a connection string; nothing connects to it.
(cd "$app" && NFHOTEL_CONNECTION="Host=localhost;Database=x;Username=x;Password=x" dotnet ef migrations script --idempotent \
  --project src/NFHotel.Infrastructure --startup-project src/NFHotel.Infrastructure \
  --msbuildprojectextensionspath g/obj/NFHotel.Infrastructure --output "$out/migrations.sql") || die "migrations script failed"

echo "==> the API image"
docker build --quiet -f "$app/Dockerfile.api" -t nfhotel-api:test "$app" >/dev/null || die "the API image did not build"
echo "==> $out/migrations.sql and nfhotel-api:test are ready"
