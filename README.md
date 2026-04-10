# unifi-docker
Unifi Access Point controller based on jacobalberty/unifi

Transformed into:

# UniFi Docker Image for External MongoDB

Custom UniFi Network Application image based on the official UniFi `.zip` release, designed to run with an external MongoDB container instead of the legacy bundled MongoDB setup.

---

## Features

* Installs UniFi from the official `.zip` release
* Uses external MongoDB (no embedded database)
* Runs UniFi as a non-root user
* Supports bind mounts for persistent data
* Clean, reproducible Docker Compose setup
* Designed for homelab and production use

---

## Image tags

Image tags follow this pattern:

* `10.2.105` = UniFi upstream version
* `10.2.105.1`, `10.2.105.2`, etc. = image revisions/fixes

Example:

```
bitctrlnl/unifi:10.2.105.5
```

---

## Requirements

* Docker
* Docker Compose
* Persistent storage for:

  * UniFi data
  * MongoDB data

---

## Quick start

### 1. Clone the repository

```bash
git clone https://github.com/bitctrlnl/unifi-docker.git
cd unifi-docker
```

---

### 2. Copy example files

```bash
cp .env.example .env
cp docker-compose.example.yaml docker-compose.yaml
mkdir -p mongo-init
cp mongo-init/init.js.example mongo-init/init.js
```

---

### 3. Configure credentials

Edit the following files:

* `.env`
* `mongo-init/init.js`

Replace all `changeme-*` values with secure passwords.

---

### 4. Start the stack

```bash
docker compose up -d
```

---

### 5. Open UniFi

Browse to:

```
https://<host>:8443
```

---

## Persistent data

This setup uses bind mounts:

* `./unifi-data:/unifi`
* `./mongo-data:/data/db`

This ensures:

* Easy backups
* Full control over data
* No hidden Docker volumes

---

## MongoDB setup

* A dedicated **application user** is created via `mongo-init/init.js`
* UniFi connects using this user
* Root Mongo credentials are only used for initialization

⚠️ Important:

MongoDB init scripts only run on a **fresh data directory**

If you change credentials later:

```bash
docker compose down
rm -rf mongo-data
docker compose up -d
```
Configuration
Supported environment variables

The container supports at least the following environment variables:

DB_URI
STATDB_URI
DB_NAME
JVM_MAX_HEAP_SIZE
JVM_INIT_HEAP_SIZE
JVM_MAX_THREAD_STACK_SIZE
LOTSOFDEVICES
UNIFI_HTTP_PORT
UNIFI_HTTPS_PORT
PORTAL_HTTP_PORT
PORTAL_HTTPS_PORT
SYSTEM_IP
UNIFI_STDOUT
Example for larger deployments

Example UniFi service configuration for a larger environment:

environment:
  DB_URI: mongodb://${MONGO_APP_USERNAME}:${MONGO_APP_PASSWORD}@unifi-mongo:27017/unifi
  STATDB_URI: mongodb://${MONGO_APP_USERNAME}:${MONGO_APP_PASSWORD}@unifi-mongo:27017/unifi_stat
  DB_NAME: unifi
  JVM_MAX_HEAP_SIZE: 4096M
  JVM_INIT_HEAP_SIZE: 4096M
  JVM_MAX_THREAD_STACK_SIZE: 1024K
  LOTSOFDEVICES: "true"

If you use larger JVM heap settings, make sure the container or host has enough memory available.

MongoDB initialization

A dedicated UniFi application user can be created through the MongoDB init script example.

The example script creates a user with read/write access to:

unifi
unifi_stat
unifi_audit

Important:

MongoDB init scripts only run when the MongoDB data directory is empty.

If you change users or passwords later, you may need a fresh MongoDB data directory for a clean initialization test.
---

## Security notes

* Change all default passwords before use
* Never expose MongoDB to the internet
* Keep `.env` private (do not commit)
* Keep `mongo-init/init.js` private
* Use a reverse proxy (Caddy, Traefik, Nginx) for external access
* Enable HTTPS properly when exposing UniFi
* Regularly back up:

  * `/unifi`
  * MongoDB data

---

## Design choices

This image intentionally:

* Avoids `.deb` installation (dependency issues)
* Uses official UniFi `.zip`
* Supports external MongoDB only
* Runs as non-root for security
* Uses bind mounts instead of Docker volumes

---

## Status

* Image build: ✔ stable
* External MongoDB: ✔ working
* Non-root execution: ✔ working
* Docker Compose: ✔ validated

This setup is suitable for:

* Homelab environments
* Advanced self-hosting
* Small production deployments
---
## Status

Current status of the project:

image build works
external MongoDB works
non-root execution works
Docker Compose deployment works

## Example files included
.env.example
docker-compose.example.yaml
mongo-init/init.js.example

These are examples only. Copy them and adjust them for your environment before deployment.
