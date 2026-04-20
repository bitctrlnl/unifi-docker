# UniFi Docker Image for External MongoDB

Custom UniFi Network Application image based on the official UniFi
`.zip` release.

This image is designed to run with an external MongoDB database instead
of the legacy bundled MongoDB setup.

------------------------------------------------------------------------

## Features

-   Installs UniFi from the official `.zip` release
-   Uses external MongoDB
-   Runs UniFi as a non-root user
-   Supports bind mounts for persistent data
-   Includes example files for Docker Compose and environment variables

------------------------------------------------------------------------

## Image tags

Image tags follow this pattern:

-   `10.2.105` = UniFi upstream version
-   `10.2.105.1`, `10.2.105.2`, etc. = image revisions and fixes

Example:

``` bash
bitctrlnl/unifi:10.2.105.10
```

------------------------------------------------------------------------

## Requirements

-   Docker
-   Docker Compose

------------------------------------------------------------------------

## Quick start

### 1. Clone the repository

``` bash
git clone https://github.com/bitctrlnl/unifi-docker.git
cd unifi-docker
```

------------------------------------------------------------------------

### 2. Copy example files

``` bash
cp .env.example .env
cp docker-compose.example.yaml docker-compose.yaml
```

------------------------------------------------------------------------

### 3. Configure credentials

Edit:

-   `.env`

Replace all placeholder passwords with secure values.

------------------------------------------------------------------------

### 4. MongoDB initialization

Ensure the MongoDB init script is present:

```
ls mongo-init
```

This repository includes:

    mongo-init/01-init-unifi-db.sh


This script will automatically:

-   Authenticate using the MongoDB root user
-   Create the UniFi application user
-   Assign permissions for:
    -   `${MONGO_DBNAME}`
    -   `${MONGO_DBNAME}_stat`
    -   `${MONGO_DBNAME}_audit`
    -   `${MONGO_DBNAME}_restore`

⚠️ Note:

MongoDB init scripts only run when the database directory
(`./mongo-data`) is empty.\
If the database already exists, the script will NOT run again.

------------------------------------------------------------------------

### 5. Make folders for bind mounts and change FS permissions

``` bash
mkdir -p unifi-data
sudo chown -R 999:999 unifi-data
sudo chmod 755 unifi-data
```

------------------------------------------------------------------------

### 6. Start the stack

``` bash
docker compose up -d
```

------------------------------------------------------------------------

### 7. Open UniFi

    https://<host>:8443

------------------------------------------------------------------------

## Persistent data

    ./unifi-data:/unifi
    ./mongo-data:/data/db

------------------------------------------------------------------------

## MongoDB initialization behavior

MongoDB init scripts:

-   Run automatically on first startup
-   Only run if `/data/db` is empty
-   Will NOT run again after initial database creation

If you need to re-run initialization:

``` bash
rm -rf mongo-data
docker compose up -d
```

⚠️ This deletes your database.

------------------------------------------------------------------------

## Security notes

-   Change all passwords before use
-   Do not expose MongoDB to the internet
-   Keep `.env` private
-   Use a reverse proxy and HTTPS if exposing UniFi externally
-   Back up UniFi and MongoDB data regularly

------------------------------------------------------------------------

## License

MIT
