#!/usr/bin/env bash
# End-to-end test of the PostgreSQL preparation (MIL-024, ADR-0011) against PostgreSQL 16
# with the real migrations of NF-Hotel/NFHotel and its API image: roles and privileges,
# the ownership transfer without data change, the internal network, the migrator, the
# API through the alias postgres, backup as nfhotel_backup and the restore drill.
#
# Usage: test-database.sh <migrations.sql> <API image>
#   migrations.sql  dotnet ef migrations script --idempotent from an NFHotel checkout
#   API image       built from Dockerfile.api of the same checkout
# It starts containers and networks named t-*, a volume t-pgdata and the network
# nfhotel-db on the local Docker, and removes them at the end.
# Exit:  0 every check passed; 1 a check failed; 2 usage error
# Needs: bash 4+, docker, openssl, age, curl, sha256sum

set -u
[[ $# == 2 && -f "$1" ]] || { echo "usage: test-database.sh <migrations.sql> <API image>" >&2; exit 2; }
MIGRATIONS="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
API_IMAGE="$2"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
W="$(mktemp -d)"; mkdir -p $W/bin $W/backups $W/etc
PG=t-pg; IMG=postgres:16-alpine
pass=0; fail=0
ok(){ echo "PASS  $1"; pass=$((pass+1)); }
ko(){ echo "FAIL  $1"; fail=$((fail+1)); }
expect_ok(){ if eval "$2" >$W/o 2>&1; then ok "$1"; else ko "$1: $(head -c 300 $W/o)"; fi; }
expect_refused(){ if eval "$2" >$W/o 2>&1; then ko "$1 (was allowed)"; else grep -qiE "permission denied|must be owner|not permitted|denied" $W/o && ok "$1" || ko "$1: unexpected error $(head -c 200 $W/o)"; fi; }
su_sql(){ docker exec -i $PG psql -X -At -v ON_ERROR_STOP=1 -U nfhotel -d nfhotel -c "$1"; }

echo "== 1. a production-like database: objects owned by the image superuser"
docker network create t-prodnet >/dev/null
docker run -d --name $PG --network t-prodnet -e POSTGRES_USER=nfhotel -e POSTGRES_PASSWORD=superpw -e POSTGRES_DB=nfhotel -v t-pgdata:/var/lib/postgresql/data $IMG >/dev/null
for i in $(seq 60); do docker exec $PG pg_isready -U nfhotel -d nfhotel >/dev/null 2>&1 && break; sleep 1; done; sleep 2
docker exec -i $PG psql -X -q -v ON_ERROR_STOP=1 -U nfhotel -d nfhotel -f - < "$MIGRATIONS" >/dev/null && ok "real migrations applied as the superuser" || ko "migrations"
su_sql "INSERT INTO room(room_number,floor,size,capacity,status,housekeeping_status) SELECT 'R'||i, 1, 20, 2, 0, 0 FROM generate_series(1,3) i; INSERT INTO guest(first_name,last_name,email,phone_number,country) SELECT 'g'||i,'x','g'||i||'@x.dk','1','DK' FROM generate_series(1,250) i;" >/dev/null
su_sql "CREATE ROLE legacy_reader LOGIN PASSWORD 'legacypw'" >/dev/null
counts(){ su_sql "SELECT (SELECT count(*) FROM room)||'/'||(SELECT count(*) FROM guest)||'/'||(SELECT count(*) FROM booking)||'/'||(SELECT string_agg(migration_id, chr(44) ORDER BY 1) FROM \"__EFMigrationsHistory\")"; }
BEFORE=$(counts); echo "      rows room/guest/booking/history: $BEFORE"
echo "      owners before: $(su_sql "SELECT string_agg(DISTINCT tableowner, ',') FROM pg_tables WHERE schemaname='public'")"

echo "== 2. dry run changes nothing"
bash $REPO/scripts/prepare-database-roles.sh --container $PG --secrets-dir $W/secrets > $W/dry 2>&1
[ "$(su_sql "SELECT count(*) FROM pg_roles WHERE rolname LIKE 'nfhotel\_%'")" = 0 ] && [ ! -d $W/secrets ] && ok "dry run: no role and no secret created" || ko "dry run changed something"
bash $REPO/scripts/verify-database.sh --container $PG >$W/v 2>&1 && ko "verify passed before the preparation" || ok "verify fails before the preparation ($(grep -c FAIL $W/v) checks)"

echo "== 3. apply with backup, ownership transfer and network join"
printf 'AGE_RECIPIENT=%s\nBACKUP_TARGET=\nBACKUP_DIR=%s\nBACKUP_CONTAINER=%s\n' "$(age-keygen -o $W/key.txt 2>&1 | sed 's/^Public key: //')" $W/backups $PG > $W/etc/backup.env
printf '#!/bin/bash\nNFHOTEL_BACKUP_SETTINGS=%s exec bash %s/scripts/backup-database.sh "$@"\n' $W/etc/backup.env "$REPO" > $W/bin/nfhotel-backup; chmod +x $W/bin/nfhotel-backup
ID_BEFORE=$(docker inspect -f '{{.Id}} {{.State.StartedAt}}' $PG)
NFHOTEL_BACKUP_COMMAND=$W/bin/nfhotel-backup bash $REPO/scripts/prepare-database-roles.sh --container $PG --secrets-dir $W/secrets --apply --transfer-ownership --connect-network > $W/apply 2>&1 && ok "prepare --apply --transfer-ownership --connect-network" || { ko "prepare failed"; cat $W/apply; }
[ "$(docker inspect -f '{{.Id}} {{.State.StartedAt}}' $PG)" = "$ID_BEFORE" ] && ok "the PostgreSQL container was not restarted or recreated" || ko "container restarted"
[ -n "$BEFORE" ] && [ "$(counts)" = "$BEFORE" ] && ok "rows and migration history unchanged ($BEFORE)" || ko "data changed: $(counts)"
ls $W/backups/*.dump.age >/dev/null 2>&1 && ok "a backup was taken before the transfer" || ko "no backup before transfer"
bash $REPO/scripts/verify-database.sh --container $PG --expect-transfer --expect-network > $W/v 2>&1 && ok "verify-database: all checks pass ($(grep -c PASS $W/v))" || { ko "verify failed"; grep FAIL $W/v; }
[ "$(stat -c %a $W/secrets/postgres-app.password)" = 600 ] && [ "$(stat -c %a $W/secrets/nfhotel-api-database.env)" = 600 ] && ok "secrets and settings files are 0600" || ko "file modes"
APP=$(cat $W/secrets/postgres-app.password); MIG=$(cat $W/secrets/postgres-migrator.password); BAK=$(cat $W/secrets/postgres-backup.password)
grep -qF "$APP" $W/apply $W/dry $W/v && ko "a password appears in the script output" || ok "no password in the script output"
docker logs $PG 2>&1 | grep -qF "$APP" && ko "a password appears in the server log" || ok "no password in the server log"

echo "== 4. idempotent second run"
H1=$(sha256sum $W/secrets/* | sha256sum)
NFHOTEL_BACKUP_COMMAND=$W/bin/nfhotel-backup bash $REPO/scripts/prepare-database-roles.sh --container $PG --secrets-dir $W/secrets --apply --transfer-ownership --connect-network > $W/apply2 2>&1 && [ "$(sha256sum $W/secrets/* | sha256sum)" = "$H1" ] && ok "second run succeeds and keeps the passwords" || { ko "second run"; tail -3 $W/apply2; }
su_sql "SELECT has_database_privilege('legacy_reader','postgres','CONNECT')" | grep -q t && ok "an existing role keeps CONNECT to the database postgres" || ko "legacy role lost access"

echo "== 5. nfhotel_app over the internal network (service name postgres)"
asapp(){ docker run --rm --network nfhotel-db -e PGPASSWORD="$APP" $IMG psql -X -At -v ON_ERROR_STOP=1 -h postgres -U nfhotel_app -d "${2:-nfhotel}" -c "$1"; }
expect_ok "app: SELECT, INSERT, UPDATE, DELETE on guest" "asapp \"INSERT INTO guest(first_name,last_name,email,phone_number,country) VALUES ('t','t','t@t','1','DK') RETURNING guest_id\" && asapp \"UPDATE guest SET country='SE' WHERE email='t@t'\" && asapp \"DELETE FROM guest WHERE email='t@t'\" && asapp 'SELECT count(*) FROM room'"
expect_refused "app: CREATE TABLE" "asapp 'CREATE TABLE x(i int)'"
expect_refused "app: DROP TABLE room" "asapp 'DROP TABLE room'"
expect_refused "app: ALTER TABLE guest" "asapp 'ALTER TABLE guest ADD COLUMN x int'"
expect_refused "app: TRUNCATE guest" "asapp 'TRUNCATE guest'"
expect_refused "app: CREATE TEMP TABLE" "asapp 'CREATE TEMP TABLE x(i int)'"
expect_refused "app: connect to the database postgres" "asapp 'SELECT 1' postgres"
expect_refused "app: read pg_authid (password hashes)" "asapp 'SELECT * FROM pg_authid'"
docker run --rm --network t-prodnet -e PGPASSWORD="$APP" $IMG psql -X -At -h $PG -U nfhotel_app -d nfhotel -c 'SELECT 1' >/dev/null 2>&1; echo "      (the old network still reaches it as before: exit $?)"
[ "$(docker network inspect -f '{{.Internal}}' nfhotel-db)" = true ] && ok "nfhotel-db is internal (no route out)" || ko "network not internal"

echo "== 6. nfhotel_migrator runs migrations as nfhotel_owner"
asmig(){ docker run --rm -i --network nfhotel-db $IMG psql -X -q -v ON_ERROR_STOP=1 "postgresql://nfhotel_migrator:$MIG@postgres:5432/nfhotel?options=-c%20role%3Dnfhotel_owner" "$@"; }
expect_ok "migrator: the idempotent migration script runs again (no change)" 'asmig -f - < "$MIGRATIONS"'
expect_ok "migrator: a new migration creates a table" "asmig -c 'CREATE TABLE future_feature(id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, note text)'"
[ "$(su_sql "SELECT tableowner FROM pg_tables WHERE tablename='future_feature'")" = nfhotel_owner ] && ok "the new table is owned by nfhotel_owner" || ko "owner of new table: $(su_sql "SELECT tableowner FROM pg_tables WHERE tablename='future_feature'")"
expect_ok "app: uses the new table with no extra grant (default privileges)" "asapp \"INSERT INTO future_feature(note) VALUES ('x')\" && asapp 'SELECT count(*) FROM future_feature'"
expect_refused "migrator without SET ROLE cannot create (no INHERIT)" "docker run --rm --network nfhotel-db -e PGPASSWORD='$MIG' $IMG psql -X -v ON_ERROR_STOP=1 -h postgres -U nfhotel_migrator -d nfhotel -c 'CREATE TABLE y(i int)'"
asmig -c 'DROP TABLE future_feature' >/dev/null

echo "== 7. the API image reads the database through the alias postgres as nfhotel_app"
TOKEN=$(openssl rand -hex 24); SIGN=$(openssl rand -hex 32); KEY=$(openssl rand -base64 32); MPW=$(openssl rand -hex 12)
cat $W/secrets/nfhotel-api-database.env > $W/api.env
printf 'ASPNETCORE_ENVIRONMENT=Production\nEncryption__PassportKey=%s\nHotelTime__TimeZoneId=Europe/Copenhagen\nApi__Token=%s\nStaff__Token__SigningKey=%s\nStaff__InitialManager__UserName=manager\nStaff__InitialManager__Password=%s\nDatabase__MigrateOnStart=false\n' "$KEY" "$TOKEN" "$SIGN" "$MPW" >> $W/api.env
docker network create t-apinet >/dev/null
docker run -d --name t-api --network nfhotel-db --env-file $W/api.env "$API_IMAGE" >/dev/null && docker network connect t-apinet t-api
for i in $(seq 40); do code=$(docker run --rm --network t-apinet curlimages/curl:8.10.1 -s -o /dev/null -w '%{http_code}' http://t-api:8080/health 2>/dev/null); [ "$code" = 200 ] && break; sleep 2; done
[ "${code:-}" = 200 ] && ok "API /health answers 200" || { ko "API health: ${code:-none}"; docker logs t-api 2>&1 | tail -15; }
STAFF=$(docker run --rm --network t-apinet curlimages/curl:8.10.1 -s -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d "{\"userName\":\"manager\",\"password\":\"$MPW\"}" http://t-api:8080/api/auth/login | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
[ -n "$STAFF" ] && ok "API sign-in works (the first manager was written as nfhotel_app)" || ko "API sign-in failed"
ROOMS=$(docker run --rm --network t-apinet curlimages/curl:8.10.1 -s -H "Authorization: Bearer $TOKEN" -H "X-Staff-Token: $STAFF" http://t-api:8080/api/rooms)
echo "$ROOMS" | grep -o '"roomNumber":"R[0-9]"' | wc -l | grep -q 3 && ok "API /api/rooms returns the 3 rooms from PostgreSQL" || ko "rooms: $(echo "$ROOMS" | head -c 200)"
docker logs t-api 2>&1 | grep -qF "$APP" && ko "the DB password appears in the API log" || ok "no DB password in the API log"

echo "== 8. backup as nfhotel_backup and restore drill"
expect_refused "backup role cannot write" "docker run --rm --network nfhotel-db -e PGPASSWORD='$BAK' $IMG psql -X -v ON_ERROR_STOP=1 -h postgres -U nfhotel_backup -d nfhotel -c \"DELETE FROM room\""
rm -f $W/backups/*
echo "BACKUP_ROLE=nfhotel_backup" >> $W/etc/backup.env
expect_ok "backup-database.sh dumps the running container as nfhotel_backup" "$W/bin/nfhotel-backup --apply"
F=$(ls $W/backups/*.dump.age | head -1)
bash $REPO/scripts/restore-drill.sh --identity $W/key.txt "$F" > $W/drill 2>&1 && ok "restore drill passes (btree_gist, EXCLUDE constraint, history)" || { ko "restore drill"; tail -5 $W/drill; }
grep -E "rows|latest migration" $W/drill | sed 's/^/      /'

echo "== cleanup"
docker rm -f t-api $PG >/dev/null; docker volume rm t-pgdata >/dev/null; docker network rm nfhotel-db t-prodnet t-apinet >/dev/null
rm -rf "$W"
echo "RESULT: $pass passed, $fail failed"
((fail == 0))
