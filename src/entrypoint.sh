#!/bin/bash
set -e

####
# Helpers
####
# If an env var exists but is empty, Odoo can blow up when it tries to parse it (ex: int('')).
# This helper forces empty or unset values to become the literal string "None" (which Odoo parses as None).
set_none_if_empty () {
  local var="$1"
  local val="${!var-}"
  if [ -z "$val" ]; then
    export "$var=None"
  fi
}

# This helper unsets vars that are empty (sometimes nicer than setting None).
unset_if_empty () {
  local var="$1"
  local val="${!var-}"
  if [ -z "$val" ]; then
    unset "$var" || true
  fi
}

####
# Common options
####
export ODOO_CONFIG="${ODOO_CONFIG:-}"
export ODOO_SAVE="${ODOO_SAVE:-False}"
export ODOO_INIT="${ODOO_INIT:-}"
export ODOO_UPDATE="${ODOO_UPDATE:-}"
export ODOO_WITHOUT_DEMO="${ODOO_WITHOUT_DEMO:-True}"
export ODOO_IMPORT_PARTIAL="${ODOO_IMPORT_PARTIAL:-}"
export ODOO_PIDFILE="${ODOO_PIDFILE:-}"
export ODOO_ADDONS_PATH="${ODOO_ADDONS_PATH:-}"
export ODOO_UPGRADE_PATH="${ODOO_UPGRADE_PATH:-}"
export ODOO_SERVER_WIDE_MODULES="${ODOO_SERVER_WIDE_MODULES:-base,rpc,web}"
export ODOO_DATA_DIR="${ODOO_DATA_DIR:-/volumes/data}"

# file-only defaults
export ODOO_ADMIN_PASSWD="${ODOO_ADMIN_PASSWD:-admin}"
export ODOO_CSV_INTERNAL_SEP="${ODOO_CSV_INTERNAL_SEP:-,}"
export ODOO_IMPORT_FILE_MAXBYTES="${ODOO_IMPORT_FILE_MAXBYTES:-10485760}"
export ODOO_IMPORT_FILE_TIMEOUT="${ODOO_IMPORT_FILE_TIMEOUT:-3}"
export ODOO_IMPORT_URL_REGEX="${ODOO_IMPORT_URL_REGEX:-^(?:http|https)://}"
export ODOO_REPORTGZ="${ODOO_REPORTGZ:-False}"

# ints and floats
export ODOO_WEBSOCKET_KEEP_ALIVE_TIMEOUT="${ODOO_WEBSOCKET_KEEP_ALIVE_TIMEOUT:-3600}"
export ODOO_WEBSOCKET_RATE_LIMIT_BURST="${ODOO_WEBSOCKET_RATE_LIMIT_BURST:-10}"
export ODOO_WEBSOCKET_RATE_LIMIT_DELAY="${ODOO_WEBSOCKET_RATE_LIMIT_DELAY:-0.2}"

####
# HTTP Service Configuration
####
export ODOO_HTTP_INTERFACE="${ODOO_HTTP_INTERFACE:-0.0.0.0}"
export ODOO_HTTP_PORT="${ODOO_HTTP_PORT:-8069}"
export ODOO_GEVENT_PORT="${ODOO_GEVENT_PORT:-8072}"
export ODOO_HTTP_ENABLE="${ODOO_HTTP_ENABLE:-True}"
export ODOO_PROXY_MODE="${ODOO_PROXY_MODE:-False}"
export ODOO_X_SENDFILE="${ODOO_X_SENDFILE:-False}"

####
# Web interface Configuration
####
export ODOO_DBFILTER="${ODOO_DBFILTER:-}"

####
# Testing Configuration
####
export ODOO_TEST_FILE="${ODOO_TEST_FILE:-}"
export ODOO_TEST_ENABLE="${ODOO_TEST_ENABLE:-False}"
export ODOO_TEST_TAGS="${ODOO_TEST_TAGS:-}"
export ODOO_SCREENCASTS="${ODOO_SCREENCASTS:-}"
export ODOO_SCREENSHOTS="${ODOO_SCREENSHOTS:-/tmp/odoo_tests}"

####
# Logging Configuration
####
export ODOO_LOGFILE="${ODOO_LOGFILE:-}"
export ODOO_SYSLOG="${ODOO_SYSLOG:-False}"
export ODOO_LOG_HANDLER="${ODOO_LOG_HANDLER:-:INFO}"
export ODOO_LOG_DB="${ODOO_LOG_DB:-}"
export ODOO_LOG_DB_LEVEL="${ODOO_LOG_DB_LEVEL:-warning}"
export ODOO_LOG_LEVEL="${ODOO_LOG_LEVEL:-info}"

####
# SMTP Configuration
####
export ODOO_EMAIL_FROM="${ODOO_EMAIL_FROM:-}"
export ODOO_FROM_FILTER="${ODOO_FROM_FILTER:-}"
export ODOO_SMTP_SERVER="${ODOO_SMTP_SERVER:-localhost}"
export ODOO_SMTP_PORT="${ODOO_SMTP_PORT:-25}"
export ODOO_SMTP_SSL="${ODOO_SMTP_SSL:-False}"
export ODOO_SMTP_USER="${ODOO_SMTP_USER:-}"
export ODOO_SMTP_PASSWORD="${ODOO_SMTP_PASSWORD:-}"
export ODOO_SMTP_SSL_CERTIFICATE_FILENAME="${ODOO_SMTP_SSL_CERTIFICATE_FILENAME:-}"
export ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME="${ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME:-}"

####
# Database related options
####
export ODOO_DB_NAME="${ODOO_DB_NAME:-}"
export ODOO_DB_USER="${ODOO_DB_USER:-}"
export ODOO_DB_PASSWORD="${ODOO_DB_PASSWORD:-}"
export ODOO_PG_PATH="${ODOO_PG_PATH:-}"
export ODOO_DB_HOST="${ODOO_DB_HOST:-}"
export ODOO_DB_REPLICA_HOST="${ODOO_DB_REPLICA_HOST:-}"

# Important: do NOT export empty strings for int options.
# Use defaults, or "None" for optional ints.
export ODOO_DB_PORT="${ODOO_DB_PORT:-5432}"
export ODOO_DB_REPLICA_PORT="${ODOO_DB_REPLICA_PORT:-None}"
export ODOO_DB_SSLMODE="${ODOO_DB_SSLMODE:-prefer}"
export ODOO_DB_APP_NAME="${ODOO_DB_APP_NAME:-odoo-{pid}}"
export ODOO_DB_MAXCONN="${ODOO_DB_MAXCONN:-64}"
export ODOO_DB_MAXCONN_GEVENT="${ODOO_DB_MAXCONN_GEVENT:-None}"
export ODOO_DB_TEMPLATE="${ODOO_DB_TEMPLATE:-template0}"

####
# Internationalisation options
####
export ODOO_LOAD_LANGUAGE="${ODOO_LOAD_LANGUAGE:-}"
export ODOO_OVERWRITE_EXISTING_TRANSLATIONS="${ODOO_OVERWRITE_EXISTING_TRANSLATIONS:-False}"

####
# Security-related options
####
export ODOO_LIST_DB="${ODOO_LIST_DB:-True}"

####
# Advanced options
####
export ODOO_DEV_MODE="${ODOO_DEV_MODE:-}"
export ODOO_STOP_AFTER_INIT="${ODOO_STOP_AFTER_INIT:-False}"
export ODOO_OSV_MEMORY_COUNT_LIMIT="${ODOO_OSV_MEMORY_COUNT_LIMIT:-0}"
export ODOO_TRANSIENT_AGE_LIMIT="${ODOO_TRANSIENT_AGE_LIMIT:-1.0}"
export ODOO_MAX_CRON_THREADS="${ODOO_MAX_CRON_THREADS:-2}"
export ODOO_LIMIT_TIME_WORKER_CRON="${ODOO_LIMIT_TIME_WORKER_CRON:-0}"
export ODOO_UNACCENT="${ODOO_UNACCENT:-False}"
export ODOO_GEOIP_CITY_DB="${ODOO_GEOIP_CITY_DB:-/usr/share/GeoIP/GeoLite2-City.mmdb}"
export ODOO_GEOIP_COUNTRY_DB="${ODOO_GEOIP_COUNTRY_DB:-/usr/share/GeoIP/GeoLite2-Country.mmdb}"

####
# Multiprocessing options
####
export ODOO_WORKERS="${ODOO_WORKERS:-0}"
export ODOO_LIMIT_MEMORY_SOFT="${ODOO_LIMIT_MEMORY_SOFT:-2147483648}"
export ODOO_LIMIT_MEMORY_SOFT_GEVENT="${ODOO_LIMIT_MEMORY_SOFT_GEVENT:-None}"
export ODOO_LIMIT_MEMORY_HARD="${ODOO_LIMIT_MEMORY_HARD:-2684354560}"
export ODOO_LIMIT_MEMORY_HARD_GEVENT="${ODOO_LIMIT_MEMORY_HARD_GEVENT:-None}"
export ODOO_LIMIT_TIME_CPU="${ODOO_LIMIT_TIME_CPU:-60}"
export ODOO_LIMIT_TIME_REAL="${ODOO_LIMIT_TIME_REAL:-120}"
export ODOO_LIMIT_TIME_REAL_CRON="${ODOO_LIMIT_TIME_REAL_CRON:--1}"
export ODOO_LIMIT_REQUEST="${ODOO_LIMIT_REQUEST:-65536}"

# Docker Specific configuration
export IMAGE_ODOO_ENTERPRISE_LOCATION="${IMAGE_ODOO_ENTERPRISE_LOCATION:-/volumes/enterprise}"
export IMAGE_EXTRA_ADDONS_LOCATION="${IMAGE_EXTRA_ADDONS_LOCATION:-/volumes/extra_addons}"

if [ -d "$IMAGE_ODOO_ENTERPRISE_LOCATION" ] && \
   [ -n "$(find "$IMAGE_ODOO_ENTERPRISE_LOCATION" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
  echo "Odoo Enterprise detected with content"
  if [ -z "$ODOO_ADDONS_PATH" ]; then
    export ODOO_ADDONS_PATH="$IMAGE_ODOO_ENTERPRISE_LOCATION"
  else
    export ODOO_ADDONS_PATH="$IMAGE_ODOO_ENTERPRISE_LOCATION,$ODOO_ADDONS_PATH"
  fi
fi

if [ -d "$IMAGE_EXTRA_ADDONS_LOCATION" ] && \
   [ -n "$(find "$IMAGE_EXTRA_ADDONS_LOCATION" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
  echo "Additional addons have been detected with content"
  if [ -z "$ODOO_ADDONS_PATH" ]; then
    export ODOO_ADDONS_PATH="$IMAGE_EXTRA_ADDONS_LOCATION"
  else
    export ODOO_ADDONS_PATH="$IMAGE_EXTRA_ADDONS_LOCATION,$ODOO_ADDONS_PATH"
  fi
fi

IMAGE_SECRETS_DIR="${IMAGE_SECRETS_DIR:-/run/secrets}"

if [ -d "$IMAGE_SECRETS_DIR" ]; then
  while IFS= read -r -d '' secret; do
    [ -f "$secret" ] || continue
    secret_name=$(basename "$secret")
    env_var=$(echo "$secret_name" | tr '[:lower:]' '[:upper:]')
    value=$(tr -d '\r' < "$secret" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [ -n "$value" ] || continue
    export "${env_var}=${value}"
  done < <(find "$IMAGE_SECRETS_DIR" -mindepth 1 -maxdepth 1 -type f -print0)
fi

# Re-normalize after secrets load too, just in case secrets set blank strings (or compose did).
set_none_if_empty ODOO_DB_REPLICA_PORT
set_none_if_empty ODOO_DB_MAXCONN_GEVENT
set_none_if_empty ODOO_LIMIT_MEMORY_SOFT_GEVENT
set_none_if_empty ODOO_LIMIT_MEMORY_HARD_GEVENT

IMAGE_CONFIG_LOCATION="${IMAGE_CONFIG_LOCATION:-/volumes/config/odoo.conf}"

# ODOO_RC is expected by Odoo for -c/--config env_name
export ODOO_RC="${ODOO_RC:-/etc/odoo/odoo.conf}"

# Substitute environment variables into the config file and write to generated config
envsubst < "${IMAGE_CONFIG_LOCATION}" > "${ODOO_RC}"

# Optional hook
/hook_setup "$@"

case "$1" in
  -- | odoo-bin)
    shift
    if [ "$1" = "scaffold" ]; then
      exec odoo-bin "$@"
    else
      wait-for-psql.py "$@"
      exec odoo-bin "$@"
    fi
    ;;
  -*)
    wait-for-psql.py "$@"
    exec odoo-bin "$@"
    ;;
  *)
    exec "$@"
    ;;
esac

exit 1