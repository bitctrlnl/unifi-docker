#!/usr/bin/env bash
set -Eeuo pipefail

mongo_init_bin="mongosh"
if ! command -v mongosh >/dev/null 2>&1; then
  mongo_init_bin="mongo"
fi

: "${MONGO_INITDB_ROOT_USERNAME:?MONGO_INITDB_ROOT_USERNAME is required}"
: "${MONGO_INITDB_ROOT_PASSWORD:?MONGO_INITDB_ROOT_PASSWORD is required}"
: "${MONGO_APP_USERNAME:?MONGO_APP_USERNAME is required}"
: "${MONGO_APP_PASSWORD:?MONGO_APP_PASSWORD is required}"

MONGO_AUTHSOURCE="${MONGO_AUTHSOURCE:-admin}"
MONGO_DBNAME="${MONGO_DBNAME:-unifi}"

"${mongo_init_bin}" --quiet <<EOF
use ${MONGO_AUTHSOURCE}
db.auth("${MONGO_INITDB_ROOT_USERNAME}", "${MONGO_INITDB_ROOT_PASSWORD}")

db = db.getSiblingDB("${MONGO_DBNAME}")

const existingUser = db.getUser("${MONGO_APP_USERNAME}")

if (existingUser) {
  print("Mongo user '${MONGO_APP_USERNAME}' already exists in db '${MONGO_DBNAME}', skipping createUser")
} else {
  db.createUser({
    user: "${MONGO_APP_USERNAME}",
    pwd: "${MONGO_APP_PASSWORD}",
    roles: [
      { db: "${MONGO_DBNAME}", role: "dbOwner" },
      { db: "${MONGO_DBNAME}_stat", role: "dbOwner" },
      { db: "${MONGO_DBNAME}_audit", role: "dbOwner" },
      { db: "${MONGO_DBNAME}_restore", role: "dbOwner" }
    ]
  })
  print("Mongo user '${MONGO_APP_USERNAME}' created")
}
EOF
