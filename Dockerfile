FROM debian:trixie-slim

LABEL maintainer="bitctrlnl"

ARG DEBIAN_FRONTEND=noninteractive
ARG UNIFI_VERSION=10.2.105
ARG UNIFI_ZIP_URL=https://dl.ui.com/unifi/${UNIFI_VERSION}/UniFi.unix.zip

ENV BASEDIR=/usr/lib/unifi \
    DATADIR=/unifi/data \
    LOGDIR=/unifi/log \
    CERTDIR=/unifi/cert \
    RUNDIR=/unifi/run \
    ORUNDIR=/var/run/unifi \
    ODATADIR=/var/lib/unifi \
    OLOGDIR=/var/log/unifi \
    CERTNAME=cert.pem \
    CERT_PRIVATE_NAME=privkey.pem \
    CERT_IS_CHAIN=false \
    BIND_PRIV=false \
    RUNAS_UID0=false \
    UNIFI_GID=999 \
    UNIFI_UID=999

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates procps; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/unifi \
    /usr/local/unifi/init.d \
    /usr/unifi/init.d \
    /usr/local/docker

COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-healthcheck.sh /usr/local/bin/
COPY docker-build.sh /usr/local/bin/
COPY functions /usr/unifi/functions
COPY import_cert /usr/unifi/init.d/
COPY pre_build /usr/local/docker/pre_build

RUN chmod +rx /usr/local/bin/docker-entrypoint.sh \
 && chmod +rx /usr/unifi/init.d/import_cert \
 && chmod +r /usr/unifi/functions \
 && chmod +rx /usr/local/bin/docker-healthcheck.sh \
 && chmod +rx /usr/local/bin/docker-build.sh \
 && chmod -R +rx /usr/local/docker/pre_build

RUN set -ex \
 && mkdir -p /usr/share/man/man1/ \
 && groupadd -r unifi -g $UNIFI_GID \
 && useradd --no-log-init -r -u $UNIFI_UID -g $UNIFI_GID unifi \
 && /usr/local/bin/docker-build.sh "${UNIFI_ZIP_URL}"

RUN mkdir -p /unifi \
 && chown unifi:unifi -R /unifi

COPY hotfixes /usr/local/unifi/hotfixes
RUN if [ -d /usr/local/unifi/hotfixes ] && [ "$(ls -A /usr/local/unifi/hotfixes 2>/dev/null)" ]; then \
      chmod +x /usr/local/unifi/hotfixes/* && run-parts /usr/local/unifi/hotfixes; \
    fi

VOLUME ["/unifi", "/unifi/run"]

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp 10001/udp

WORKDIR /unifi

HEALTHCHECK --start-period=5m CMD /usr/local/bin/docker-healthcheck.sh || exit 1

USER unifi
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["unifi"]
