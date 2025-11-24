#!/bin/bash

set -e

####
# Common options
####
# specify alternate config file (default '')
export ODOO_CONFIG="${ODOO_CONFIG:-}"

# save configuration (default False)
export ODOO_SAVE=${ODOO_SAVE:-False}

# install modules (default '')
export ODOO_INIT="${ODOO_INIT:-}"

# update modules (default '')
export ODOO_UPDATE="${ODOO_UPDATE:-}"

# don't install demo data in new databases (default True)
export ODOO_WITHOUT_DEMO=${ODOO_WITHOUT_DEMO:-True}

# partial import file (default '')
export ODOO_IMPORT_PARTIAL="${ODOO_IMPORT_PARTIAL:-}"

# pidfile (default '')
export ODOO_PIDFILE="${ODOO_PIDFILE:-}"

# addons_path (default '')
export ODOO_ADDONS_PATH="${ODOO_ADDONS_PATH:-}"

# upgrade_path (default '')
export ODOO_UPGRADE_PATH="${ODOO_UPGRADE_PATH:-}"

# server-wide modules (default base,rpc,web)
export ODOO_SERVER_WIDE_MODULES="${ODOO_SERVER_WIDE_MODULES:-base,rpc,web}"

# data_dir (default /var/lib/odoo)
export ODOO_DATA_DIR="${ODOO_DATA_DIR:-/volumes/data}"

# file-only defaults (commonly used in configs)
export ODOO_ADMIN_PASSWD="${ODOO_ADMIN_PASSWD:-admin}"
export ODOO_CSV_INTERNAL_SEP="${ODOO_CSV_INTERNAL_SEP:-,}"
export ODOO_IMPORT_FILE_MAXBYTES="${ODOO_IMPORT_FILE_MAXBYTES:-10485760}"     # 10 * 1024 * 1024
export ODOO_IMPORT_FILE_TIMEOUT="${ODOO_IMPORT_FILE_TIMEOUT:-3}"
export ODOO_IMPORT_URL_REGEX="${ODOO_IMPORT_URL_REGEX:-^(?:http|https)://}"
export ODOO_REPORTGZ=${ODOO_REPORTGZ:-False}
export ODOO_WEBSOCKET_KEEP_ALIVE_TIMEOUT="${ODOO_WEBSOCKET_KEEP_ALIVE_TIMEOUT:-3600}"
export ODOO_WEBSOCKET_RATE_LIMIT_BURST="${ODOO_WEBSOCKET_RATE_LIMIT_BURST:-10}"
export ODOO_WEBSOCKET_RATE_LIMIT_DELAY="${ODOO_WEBSOCKET_RATE_LIMIT_DELAY:-0.2}"

####
# HTTP Service Configuration
####
# http_interface (default 0.0.0.0)
export ODOO_HTTP_INTERFACE="${ODOO_HTTP_INTERFACE:-0.0.0.0}"

# http_port (default 8069)
export ODOO_HTTP_PORT=${ODOO_HTTP_PORT:-8069}

# gevent_port (default 8072)
export ODOO_GEVENT_PORT=${ODOO_GEVENT_PORT:-8072}

# http_enable (default True)
export ODOO_HTTP_ENABLE=${ODOO_HTTP_ENABLE:-True}

# proxy_mode (default False)
export ODOO_PROXY_MODE=${ODOO_PROXY_MODE:-False}

# x_sendfile (default False)
export ODOO_X_SENDFILE=${ODOO_X_SENDFILE:-False}

####
# Web interface Configuration
####
# dbfilter (default '')
export ODOO_DBFILTER="${ODOO_DBFILTER:-}"

####
# Testing Configuration
####
# test_file (default '')
export ODOO_TEST_FILE="${ODOO_TEST_FILE:-}"

# test_enable (default False)
export ODOO_TEST_ENABLE=${ODOO_TEST_ENABLE:-False}

# test_tags (default '')
export ODOO_TEST_TAGS="${ODOO_TEST_TAGS:-}"

# screencasts (default '')
export ODOO_SCREENCASTS="${ODOO_SCREENCASTS:-}"

# screenshots (default /tmp/odoo_tests)
export ODOO_SCREENSHOTS="${ODOO_SCREENSHOTS:-/tmp/odoo_tests}"

####
# Logging Configuration
####
# logfile (default '')
export ODOO_LOGFILE="${ODOO_LOGFILE:-}"

# syslog (default False)
export ODOO_SYSLOG=${ODOO_SYSLOG:-False}

# log_handler (default :INFO)
export ODOO_LOG_HANDLER="${ODOO_LOG_HANDLER:-:INFO}"

# log_db (default '')
export ODOO_LOG_DB="${ODOO_LOG_DB:-}"

# log_db_level (default warning)
export ODOO_LOG_DB_LEVEL="${ODOO_LOG_DB_LEVEL:-warning}"

# log_level (default info)
export ODOO_LOG_LEVEL="${ODOO_LOG_LEVEL:-info}"

####
# SMTP Configuration
####
# email_from (default '')
export ODOO_EMAIL_FROM="${ODOO_EMAIL_FROM:-}"

# from_filter (default '')
export ODOO_FROM_FILTER="${ODOO_FROM_FILTER:-}"

# smtp_server (default localhost)
export ODOO_SMTP_SERVER="${ODOO_SMTP_SERVER:-localhost}"

# smtp_port (default 25)
export ODOO_SMTP_PORT=${ODOO_SMTP_PORT:-25}

# smtp_ssl (default False)
export ODOO_SMTP_SSL=${ODOO_SMTP_SSL:-False}

# smtp_user (default '')
export ODOO_SMTP_USER="${ODOO_SMTP_USER:-}"

# smtp_password (default '')
export ODOO_SMTP_PASSWORD="${ODOO_SMTP_PASSWORD:-}"

# smtp_ssl_certificate_filename (default '')
export ODOO_SMTP_SSL_CERTIFICATE_FILENAME="${ODOO_SMTP_SSL_CERTIFICATE_FILENAME:-}"

# smtp_ssl_private_key_filename (default '')
export ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME="${ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME:-}"

####
# Database related options
####
# db_name (default '')
export ODOO_DB_NAME="${ODOO_DB_NAME:-}"

# db_user (default '')
export ODOO_DB_USER="${ODOO_DB_USER:-}"

# db_password (default '')
export ODOO_DB_PASSWORD="${ODOO_DB_PASSWORD:-}"

# pg_path (default '')
export ODOO_PG_PATH="${ODOO_PG_PATH:-}"

# db_host (default '')
export ODOO_DB_HOST="${ODOO_DB_HOST:-}"

# db_replica_host (default '')
export ODOO_DB_REPLICA_HOST="${ODOO_DB_REPLICA_HOST:-}"

# db_port (default '')
export ODOO_DB_PORT="${ODOO_DB_PORT:-}"

# db_replica_port (default '')
export ODOO_DB_REPLICA_PORT="${ODOO_DB_REPLICA_PORT:-}"

# db_sslmode (default prefer)
export ODOO_DB_SSLMODE="${ODOO_DB_SSLMODE:-prefer}"

# db_app_name (default odoo-{pid})
export ODOO_DB_APP_NAME="${ODOO_DB_APP_NAME:-odoo-{pid}}"

# db_maxconn (default 64)
export ODOO_DB_MAXCONN=${ODOO_DB_MAXCONN:-64}

# db_maxconn_gevent (default '')
export ODOO_DB_MAXCONN_GEVENT="${ODOO_DB_MAXCONN_GEVENT:-}"

# db_template (default template0)
export ODOO_DB_TEMPLATE="${ODOO_DB_TEMPLATE:-template0}"

####
# Internationalisation options
####
# load_language (default '')
export ODOO_LOAD_LANGUAGE="${ODOO_LOAD_LANGUAGE:-}"

# overwrite_existing_translations (default False)
export ODOO_OVERWRITE_EXISTING_TRANSLATIONS=${ODOO_OVERWRITE_EXISTING_TRANSLATIONS:-False}

####
# Security-related options
####
# list_db (default True)
export ODOO_LIST_DB=${ODOO_LIST_DB:-True}

####
# Advanced options
####
# dev_mode (default '')
export ODOO_DEV_MODE="${ODOO_DEV_MODE:-}"

# stop_after_init (default False)
export ODOO_STOP_AFTER_INIT=${ODOO_STOP_AFTER_INIT:-False}

# osv_memory_count_limit (default 0)
export ODOO_OSV_MEMORY_COUNT_LIMIT=${ODOO_OSV_MEMORY_COUNT_LIMIT:-0}

# transient_age_limit (default 1.0)
export ODOO_TRANSIENT_AGE_LIMIT=${ODOO_TRANSIENT_AGE_LIMIT:-1.0}

# max_cron_threads (default 2)
export ODOO_MAX_CRON_THREADS=${ODOO_MAX_CRON_THREADS:-2}

# limit_time_worker_cron (default 0)
export ODOO_LIMIT_TIME_WORKER_CRON=${ODOO_LIMIT_TIME_WORKER_CRON:-0}

# unaccent (default False)
export ODOO_UNACCENT=${ODOO_UNACCENT:-False}

# geoip_city_db (default /usr/share/GeoIP/GeoLite2-City.mmdb)
export ODOO_GEOIP_CITY_DB="${ODOO_GEOIP_CITY_DB:-/usr/share/GeoIP/GeoLite2-City.mmdb}"

# geoip_country_db (default /usr/share/GeoIP/GeoLite2-Country.mmdb)
export ODOO_GEOIP_COUNTRY_DB="${ODOO_GEOIP_COUNTRY_DB:-/usr/share/GeoIP/GeoLite2-Country.mmdb}"

####
# Multiprocessing options (POSIX only)
####
# workers (default 0)
export ODOO_WORKERS=${ODOO_WORKERS:-0}

# limit_memory_soft (default 2147483648)
export ODOO_LIMIT_MEMORY_SOFT=${ODOO_LIMIT_MEMORY_SOFT:-2147483648}

# limit_memory_soft_gevent (default '')
export ODOO_LIMIT_MEMORY_SOFT_GEVENT="${ODOO_LIMIT_MEMORY_SOFT_GEVENT:-}"

# limit_memory_hard (default 2684354560)
export ODOO_LIMIT_MEMORY_HARD=${ODOO_LIMIT_MEMORY_HARD:-2684354560}

# limit_memory_hard_gevent (default '')
export ODOO_LIMIT_MEMORY_HARD_GEVENT="${ODOO_LIMIT_MEMORY_HARD_GEVENT:-}"

# limit_time_cpu (default 60)
export ODOO_LIMIT_TIME_CPU=${ODOO_LIMIT_TIME_CPU:-60}

# limit_time_real (default 120)
export ODOO_LIMIT_TIME_REAL=${ODOO_LIMIT_TIME_REAL:-120}

# limit_time_real_cron (default -1)
export ODOO_LIMIT_TIME_REAL_CRON=${ODOO_LIMIT_TIME_REAL_CRON:--1}

# limit_request (default 65536)
export ODOO_LIMIT_REQUEST=${ODOO_LIMIT_REQUEST:-65536}


# Docker Specific configuration
IMAGE_ODOO_ENTERPRISE_LOCATION="${IMAGE_ODOO_ENTERPRISE_LOCATION:-/volumes/enterprise}"

# If the enterprise folder is NON-EMPTY, add it to ODOO_ADDONS_PATH
if [ -d "$IMAGE_ODOO_ENTERPRISE_LOCATION" ] && \
   [ -n "$(find "$IMAGE_ODOO_ENTERPRISE_LOCATION" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
  echo "Odoo Enterprise detected with content"

  if [ -z "$ODOO_ADDONS_PATH" ]; then
    export ODOO_ADDONS_PATH="$IMAGE_ODOO_ENTERPRISE_LOCATION"
  else
    export ODOO_ADDONS_PATH="$IMAGE_ODOO_ENTERPRISE_LOCATION,$ODOO_ADDONS_PATH"
  fi
fi


# If the enterprise folder exists, add it to the ODOO_ADDONS_PATH
if [ -d "${IMAGE_EXTRA_ADDONS_LOCATION}" ]; then
    echo "Additional addons have been detected"

    if [ -z "$ODOO_ADDONS_PATH" ]; then
        export ODOO_ADDONS_PATH="$IMAGE_EXTRA_ADDONS_LOCATION"
    else
        export ODOO_ADDONS_PATH="$ODOO_ADDONS_PATH,$IMAGE_EXTRA_ADDONS_LOCATION"
    fi
fi

# Guard-rail: unset envs that should be integers if they are non-numeric (Odoo will fall back to defaults)
INT_VARS=(
  ODOO_HTTP_PORT
  ODOO_GEVENT_PORT
  ODOO_SMTP_PORT
  ODOO_DB_PORT
  ODOO_DB_REPLICA_PORT
  ODOO_DB_MAXCONN
  ODOO_DB_MAXCONN_GEVENT
  ODOO_LIMIT_MEMORY_SOFT
  ODOO_LIMIT_MEMORY_HARD
  ODOO_LIMIT_MEMORY_SOFT_GEVENT
  ODOO_LIMIT_MEMORY_HARD_GEVENT
  ODOO_LIMIT_TIME_CPU
  ODOO_LIMIT_TIME_REAL
  ODOO_LIMIT_TIME_REAL_CRON
  ODOO_LIMIT_REQUEST
  ODOO_MAX_CRON_THREADS
)
for name in "${INT_VARS[@]}"; do
  val="${!name-}"
  if [ -z "${val}" ] || ! [[ "${val}" =~ ^-?[0-9]+$ ]]; then
    unset "${name}"
  fi
done


# Set the secrets directory from the environment variable IMAGE_SECRETS_DIR (defaulting to /run/secrets)
IMAGE_SECRETS_DIR="${IMAGE_SECRETS_DIR:-/run/secrets}"

# Set the secrets directory from the environment variable IMAGE_SECRETS_DIR (defaulting to /run/secrets)
# Loop through each file in the configured secrets directory and export its content as an environment variable
if [ -d "$IMAGE_SECRETS_DIR" ]; then
    while IFS= read -r -d '' secret; do
        [ -f "$secret" ] || continue
        secret_name=$(basename "$secret")
        env_var=$(echo "$secret_name" | tr '[:lower:]' '[:upper:]')
        # Read and trim; skip empty values to avoid breaking int/choice options
        value=$(tr -d '\r' < "$secret" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        [ -n "$value" ] || continue
        export "${env_var}=${value}"
    done < <(find "$IMAGE_SECRETS_DIR" -mindepth 1 -maxdepth 1 -type f -print0)
fi


IMAGE_CONFIG_LOCATION="${IMAGE_CONFIG_LOCATION:-/volumes/config/odoo.conf}"

# Substitute environment variables into the config file
# and write them to the generated config file
envsubst < "${IMAGE_CONFIG_LOCATION}" > "${ODOO_RC}"

/hook_setup "$@"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py "$@"
            exec odoo "$@"
        fi
        ;;
    -*)
        wait-for-psql.py "$@"
        exec odoo "$@"
        ;;
    *)
        exec "$@"
esac

exit 1
