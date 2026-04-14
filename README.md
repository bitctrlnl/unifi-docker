# UniFi Docker Image for External MongoDB

Custom UniFi Network Application image based on the official UniFi `.zip` release.

This image is designed to run with an external MongoDB database instead of the legacy bundled MongoDB setup.

---

## Features

* Installs UniFi from the official `.zip` release
* Uses external MongoDB
* Runs UniFi as a non-root user
* Supports bind mounts for persistent data
* Includes example files for Docker Compose and environment variables

---

## Image tags

Image tags follow this pattern:

* `10.2.105` = UniFi upstream version
* `10.2.105.1`, `10.2.105.2`, etc. = image revisions and fixes

Example:

```bash
bitctrlnl/unifi:10.2.105.5
```

---

## Requirements

* Docker
* Docker Compose

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

Edit:

* `.env`
* `mongo-init/init.js`

Replace all placeholder passwords with secure values.

---
### 4. Make folders for bind mounts and change FS permissions

This image runs as the non-root `unifi` user (uid/gid 999).
When using a bind mount like `./unifi-data:/unifi`, the mounted host directory must be writable by uid/gid 999.
If not, UniFi may fail to create `/unifi/data` and `/unifi/log`, and remain stuck during startup.

Run: 

```
mkdir -p unifi-data
sudo chown -R 999:999 unifi-data
sudo chmod 755 unifi-data
```

The container runs as non root, so it has to have a place thats writable.

If you get errors during the startup of the container, the'll look like the following:
```
mkdir: cannot create directory '/unifi/data': Permission denied
mkdir: cannot create directory '/unifi/log': Permission denied
/usr/local/bin/docker-entrypoint.sh: line 93: /unifi/data/system.properties: No such file or directory
WARN Unable to load properties from '/usr/lib/unifi/data/system.properties' - /usr/lib/unifi/data/system.properties (No such file or directory)
Failed to create parent directories for [/usr/lib/unifi/logs/server.log]
openFile(logs/server.log,true) call failed. java.io.FileNotFoundException: logs/server.log (No such file or directory)
```


### 5. Start the stack

```bash
docker compose up -d
```

---

### 6. Open UniFi

```text
https://<host>:8443
```

---

## Persistent data

This setup uses bind mounts:

```text
./unifi-data:/unifi
./mongo-data:/data/db
```

---

## Configuration

### Supported environment variables

* DB_URI
* STATDB_URI
* DB_NAME
* JVM_MAX_HEAP_SIZE
* JVM_INIT_HEAP_SIZE
* JVM_MAX_THREAD_STACK_SIZE
* LOTSOFDEVICES
* UNIFI_HTTP_PORT
* UNIFI_HTTPS_PORT
* SYSTEM_IP
* UNIFI_STDOUT

---

### Example for larger deployments

```yaml
environment:
  JVM_MAX_HEAP_SIZE: 4096M
  JVM_INIT_HEAP_SIZE: 4096M
  JVM_MAX_THREAD_STACK_SIZE: 1024K
  LOTSOFDEVICES: "true"
```

---

## MongoDB initialization

MongoDB init scripts only run when the data directory is empty.

---

## Security notes

* Change all passwords before use
* Do not expose MongoDB to the internet
* Keep `.env` private
* Keep `mongo-init/init.js` private
* Use a reverse proxy and HTTPS if exposing UniFi externally
* Back up UniFi and MongoDB data regularly

---

## Status

* Image works
* External MongoDB works
* Non-root execution works
* Docker Compose setup works

---

## Included example files

* `.env.example`
* `docker-compose.example.yaml`
* `mongo-init/init.js.example`

---
## Versioning & Release Policy

This image follows UniFi versioning with an additional patch level:

- `10.2.105` → stable base version (recommended)
- `10.2.105.x` → custom patched builds

Example:
- `10.2.105.5` = UniFi 10.2.105 with 5 internal fixes/improvements

### Usage recommendation

Always pin to a specific version:

```yaml
image: bitctrlnl/unifi:10.2.105.10
```

## License

MIT
