#!/usr/bin/env bash
set -euo pipefail

tryfail() {
    local s=0
    for i in $(seq 1 5); do
        [ "$i" -gt 1 ] && sleep 10
        "$@" && s=0 && break || s=$?
    done
    return "$s"
}

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    echo "please pass PKGURL as argument"
    exit 1
fi

apt-get update
apt-get install -qy --no-install-recommends \
    ca-certificates \
    curl \
    openjdk-25-jre-headless \
    procps \
    unzip \
    libcap2-bin \
    tzdata

if [ -d "/usr/local/docker/pre_build/$(dpkg --print-architecture)" ]; then
    find "/usr/local/docker/pre_build/$(dpkg --print-architecture)" -type f -exec '{}' \;
fi

UNIFI_ZIP_URL="${1%.deb}.zip"

tryfail curl -fL -o /tmp/unifi.zip "${UNIFI_ZIP_URL}"

rm -rf /usr/lib/unifi
unzip -q /tmp/unifi.zip -d /usr/lib

if [ -d /usr/lib/UniFi ]; then
    mv /usr/lib/UniFi /usr/lib/unifi
elif [ ! -d /usr/lib/unifi ]; then
    echo "UniFi directory not found after unzip"
    exit 1
fi

rm -f /tmp/unifi.zip
chown -R unifi:unifi /usr/lib/unifi

rm -rf /var/lib/apt/lists/*

rm -rf "${ODATADIR}" "${OLOGDIR}" "${ORUNDIR}" \
       "${BASEDIR}/data" "${BASEDIR}/run" "${BASEDIR}/logs"

mkdir -p "${DATADIR}" "${LOGDIR}" "${RUNDIR}" "${CERTDIR}" /var/cert

ln -sfn "${DATADIR}" "${BASEDIR}/data"
ln -sfn "${RUNDIR}" "${BASEDIR}/run"
ln -sfn "${LOGDIR}" "${BASEDIR}/logs"

ln -sfn "${DATADIR}" "${ODATADIR}"
ln -sfn "${LOGDIR}" "${OLOGDIR}"
ln -sfn "${RUNDIR}" "${ORUNDIR}"
ln -sfn "${CERTDIR}" /var/cert/unifi

chown -R unifi:unifi "${DATADIR}" "${LOGDIR}" "${RUNDIR}" "${CERTDIR}"
