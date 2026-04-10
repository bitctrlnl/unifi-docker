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

