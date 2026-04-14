#!/usr/bin/env bash

. /usr/unifi/functions

# Check that any included hotfixes have been properly applied and exit if not
if ! validate; then
  echo "Missing an included hotfix"
  exit 1
fi

exit_handler() {
    log "Exit signal received, shutting down"
    java -jar ${BASEDIR}/lib/ace.jar stop
    for i in `seq 1 10` ; do
        [ -z "$(pgrep -f ${BASEDIR}/lib/ace.jar)" ] && break
        # graceful shutdown
        [ $i -gt 1 ] && [ -d ${BASEDIR}/run ] && touch ${BASEDIR}/run/server.stop || true
        # savage shutdown
        [ $i -gt 7 ] && pkill -f ${BASEDIR}/lib/ace.jar || true
        sleep 1
    done
    # shutdown mongod
    if [ -f ${MONGOLOCK} ]; then
        mongo localhost:${MONGOPORT} --eval "db.getSiblingDB('admin').shutdownServer()" >/dev/null 2>&1
    fi
    exit ${?};
}

trap 'kill ${!}; exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

[ "x${JAVA_HOME}" != "x" ] || set_java_home

MONGOPORT=27117

CODEPATH=${BASEDIR}
DATALINK=${BASEDIR}/data
LOGLINK=${BASEDIR}/logs
RUNLINK=${BASEDIR}/run

DIRS="${RUNDIR} ${LOGDIR} ${DATADIR} ${BASEDIR}"

JVM_MAX_HEAP_SIZE=${JVM_MAX_HEAP_SIZE:-1024M}

MONGOLOCK="${DATAPATH}/db/mongod.lock"
JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} --add-opens=java.base/java.time=ALL-UNNAMED -Dunifi.datadir=${DATADIR} -Dunifi.logdir=${LOGDIR} -Dunifi.rundir=${RUNDIR}"
PIDFILE=/var/run/unifi/unifi.pid

if [ ! -z "${JVM_MAX_HEAP_SIZE}" ]; then
  JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Xmx${JVM_MAX_HEAP_SIZE}"
fi

if [ ! -z "${JVM_INIT_HEAP_SIZE}" ]; then
  JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Xms${JVM_INIT_HEAP_SIZE}"
fi

if [ ! -z "${JVM_MAX_THREAD_STACK_SIZE}" ]; then
  JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Xss${JVM_MAX_THREAD_STACK_SIZE}"
fi

JVM_OPTS="${JVM_EXTRA_OPTS}
  -Djava.awt.headless=true
  -Dfile.encoding=UTF-8"

rm -f /var/run/unifi/unifi.pid

run-parts /usr/local/unifi/init.d
run-parts /usr/unifi/init.d

if [ -d "/unifi/init.d" ]; then
    run-parts "/unifi/init.d"
fi

confSet () {
  file=$1
  key=$2
  value=$3
  if [ "$newfile" != true ] && grep -q "^${key} *=" "$file"; then
    ekey=$(echo "$key" | sed -e 's/[]\/$*.^|[]/\\&/g')
    evalue=$(echo "$value" | sed -e 's/[\/&]/\\&/g')
    sed -i "s/^\(${ekey}\s*=\s*\).*$/\1${evalue}/" "$file"
  else
    echo "${key}=${value}" >> "$file"
  fi
}

confFile="${DATADIR}/system.properties"
if [ -e "$confFile" ]; then
  newfile=false
else
  newfile=true
fi

declare -A settings

h2mb() {
  awkcmd='
    /[0-9]$/{print $1/1024/1024;next};
    /[mM]$/{printf "%u\n", $1;next};
    /[kK]$/{printf "%u\n", $1/1024;next}
    /[gG]$/{printf "%u\n", $1*1024;next}
  '
  echo $1 | awk "${awkcmd}"
}

if ! [[ -z "$LOTSOFDEVICES" ]]; then
  settings["unifi.G1GC.enabled"]="true"
  settings["unifi.xms"]="$(h2mb $JVM_INIT_HEAP_SIZE)"
  settings["unifi.xmx"]="$(h2mb ${JVM_MAX_HEAP_SIZE:-1024M})"
  settings["unifi.db.nojournal"]="true"
  settings["unifi.db.extraargs"]="--quiet"
fi

if ! [[ -z "$DB_URI" || -z "$STATDB_URI" || -z "$DB_NAME" ]]; then
  settings["db.mongo.local"]="false"
  settings["db.mongo.uri"]="$DB_URI"
  settings["statdb.mongo.uri"]="$STATDB_URI"
  settings["unifi.db.name"]="$DB_NAME"
fi

if ! [[ -z "$SYSTEM_IP"  ]]; then
  settings["system_ip"]="$SYSTEM_IP"
fi

if ! [[ -z "$PORTAL_HTTP_PORT"  ]]; then
  settings["portal.http.port"]="$PORTAL_HTTP_PORT"
fi

if ! [[ -z "$PORTAL_HTTPS_PORT"  ]]; then
  settings["portal.https.port"]="$PORTAL_HTTPS_PORT"
fi

if ! [[ -z "$UNIFI_HTTP_PORT"  ]]; then
  settings["unifi.http.port"]="$UNIFI_HTTP_PORT"
fi

if ! [[ -z "$UNIFI_HTTPS_PORT"  ]]; then
  settings["unifi.https.port"]="$UNIFI_HTTPS_PORT"
fi

if ! [[ -z "$SMTP_STARTTLS_ENABLED"  ]]; then
  settings["smtp.starttls_enabled"]="$SMTP_STARTTLS_ENABLED"
fi

if [[ "$UNIFI_ECC_CERT" == "true" ]]; then
  settings["unifi.https.sslEnabledProtocols"]="TLSv1.2"
  settings["unifi.https.ciphers"]="TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"
fi

if [[ "$UNIFI_STDOUT" == "true" ]]; then
  settings["unifi.logStdout"]="true"
fi

cd ${BASEDIR}

if [[ "$1" == "unifi" ]]; then
    log 'Starting unifi controller service.'

    # --- FAIL FAST CHECK FOR BIND MOUNT PERMISSIONS ---
    for dir in "${DATADIR}" "${LOGDIR}"; do
        if [ ! -d "${dir}" ]; then
            if [ "${UNSAFE_IO}" == "true" ]; then
                rm -rf "${dir}"
            fi
            if ! mkdir -p "${dir}"; then
                log "ERROR: Cannot create ${dir}"
                log "ERROR: The /unifi bind mount is not writable by uid $(id -u) gid $(id -g)"
                log "ERROR: Fix on host with:"
                log "ERROR:   chown -R $(id -u):$(id -g) <your-unifi-data-dir>"
                exit 1
            fi
        fi

        if ! touch "${dir}/.write-test" 2>/dev/null; then
            log "ERROR: ${dir} is not writable by uid $(id -u) gid $(id -g)"
            log "ERROR: UniFi cannot write system.properties or logs"
            exit 1
        fi

        rm -f "${dir}/.write-test"
    done
    # --- END FAIL FAST CHECK ---

    for key in "${!settings[@]}"; do
      confSet "$confFile" "$key" "${settings[$key]}"
    done

    exec java ${JVM_OPTS} -jar ${BASEDIR}/lib/ace.jar start
else
    log "Executing: $@"
    exec "$@"
fi

exit 1
