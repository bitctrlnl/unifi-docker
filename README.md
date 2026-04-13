# unifi-docker
Unifi Access Point controller based on jacobalberty/unifi

Transformed into:

# UniFi Docker Image for External MongoDB

Custom UniFi Network Application image based on the official UniFi `.zip` release.

This image is intended for deployments that use an external MongoDB database instead of the legacy bundled MongoDB setup.

## Features

- Installs UniFi from the official `.zip` release
- Uses external MongoDB
- Runs UniFi as a non-root user
- Supports bind mounts for persistent data
- Includes example files for Docker Compose and environment variables

## Image tags

Image tags follow this pattern:

- `10.2.105` = UniFi upstream version
- `10.2.105.1`, `10.2.105.2`, etc. = image revisions and fixes

Example:

bitctrlnl/unifi:10.2.105.5

## Requirements

- Docker
- Docker Compose

## Quick start

### 1. Clone the repository
```
git clone https://github.com/bitctrlnl/unifi-docker.git
cd unifi-docker
```
### 2. Copy example files
```
cp .env.example .env  
cp docker-compose.example.yaml docker-compose.yaml  
mkdir -p mongo-init  
cp mongo-init/init.js.example mongo-init/init.js  
```
### 3. Configure credentials

Edit:
- `.env`
- `mongo-init/init.js`

### 4. Start the stack
```
docker compose up -d
```
### 5. Open UniFi
```
https://<host>:8443
```
## Persistent data

- ./unifi-data:/unifi
- ./mongo-data:/data/db

## Configuration

### Supported environment variables

- DB_URI
- STATDB_URI
- DB_NAME
- JVM_MAX_HEAP_SIZE
- JVM_INIT_HEAP_SIZE
- JVM_MAX_THREAD_STACK_SIZE
- LOTSOFDEVICES
- UNIFI_HTTP_PORT
- UNIFI_HTTPS_PORT
- SYSTEM_IP
- UNIFI_STDOUT

### Example for larger deployments
```
environment:
  - JVM_MAX_HEAP_SIZE: 4096M
  - JVM_INIT_HEAP_SIZE: 4096M
  - JVM_MAX_THREAD_STACK_SIZE: 1024K
  - LOTSOFDEVICES: "true"
```
## MongoDB initialization

Init scripts only run on a fresh database.

## Security notes

- Change all passwords
- Do not expose MongoDB
- Keep `.env` private
- Use HTTPS/reverse proxy for external access
- Back up UniFi + MongoDB data

## Status

- Image works
- External Mongo works
- Non-root works
- Compose works
