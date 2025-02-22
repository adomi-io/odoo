#!/bin/bash

set -e

####
# Common options
####

# specify alternate config file (default None)
export ODOO_CONFIG="${ODOO_CONFIG:-}"

# save configuration (default False)
export ODOO_SAVE="${ODOO_SAVE:-False}"

# install modules (default None)
export ODOO_INIT="${ODOO_INIT:-}"

# update modules (default None)
export ODOO_UPDATE="${ODOO_UPDATE:-}"

# disable loading demo data (default False)
export ODOO_WITHOUT_DEMO="${ODOO_WITHOUT_DEMO:-False}"

# partial import file (default '')
export ODOO_IMPORT_PARTIAL="${ODOO_IMPORT_PARTIAL:-''}"

# pidfile (default None)
export ODOO_PIDFILE="${ODOO_PIDFILE:-}"

# addons_path (default None)
export ODOO_ADDONS_PATH="${ODOO_ADDONS_PATH:-}"

# upgrade_path (default None)
export ODOO_UPGRADE_PATH="${ODOO_UPGRADE_PATH:-}"

# server-wide modules (default base,web)
export ODOO_SERVER_WIDE_MODULES="${ODOO_SERVER_WIDE_MODULES:-base,web}"

# data_dir (default /var/lib/odoo)
export ODOO_DATA_DIR="${ODOO_DATA_DIR:-/volumes/data}"


####
# HTTP Service Configuration
####

# http_interface (default '')
export ODOO_HTTP_INTERFACE="${ODOO_HTTP_INTERFACE:-}"

# http_port (default 8069)
export ODOO_HTTP_PORT="${ODOO_HTTP_PORT:-8069}"

# gevent_port (default 8072)
export ODOO_GEVENT_PORT="${ODOO_GEVENT_PORT:-8072}"

# http_enable (default True)
export ODOO_HTTP_ENABLE="${ODOO_HTTP_ENABLE:-True}"

# proxy_mode (default False)
export ODOO_PROXY_MODE="${ODOO_PROXY_MODE:-False}"

# x_sendfile (default False)
export ODOO_X_SENDFILE="${ODOO_X_SENDFILE:-False}"


####
# Web interface Configuration
####

# dbfilter (default '')
export ODOO_DBFILTER="${ODOO_DBFILTER:-}"


####
# Testing Configuration
####

# test_file (default False)
export ODOO_TEST_FILE="${ODOO_TEST_FILE:-False}"

# test_enable (default None)
export ODOO_TEST_ENABLE="${ODOO_TEST_ENABLE:-}"

# test_tags (default None)
export ODOO_TEST_TAGS="${ODOO_TEST_TAGS:-}"

# screencasts (default None)
export ODOO_SCREENCASTS="${ODOO_SCREENCASTS:-}"

# screenshots (default /tmp/odoo_tests)
export ODOO_SCREENSHOTS="${ODOO_SCREENSHOTS:-/tmp/odoo_tests}"


####
# Logging Configuration
####

# logfile (default None)
export ODOO_LOGFILE="${ODOO_LOGFILE:-}"

# syslog (default False)
export ODOO_SYSLOG="${ODOO_SYSLOG:-False}"

# log_handler (default :INFO, but repeated 3 times for shortcuts)
export ODOO_LOG_HANDLER="${ODOO_LOG_HANDLER:-:INFO}"

# log_db (default False)
export ODOO_LOG_DB="${ODOO_LOG_DB:-False}"

# log_db_level (default warning)
export ODOO_LOG_DB_LEVEL="${ODOO_LOG_DB_LEVEL:-warning}"

# log_level (default info)
export ODOO_LOG_LEVEL="${ODOO_LOG_LEVEL:-info}"


####
# SMTP Configuration
####

# email_from (default False)
export ODOO_EMAIL_FROM="${ODOO_EMAIL_FROM:-False}"

# from_filter (default False)
export ODOO_FROM_FILTER="${ODOO_FROM_FILTER:-False}"

# smtp_server (default localhost)
export ODOO_SMTP_SERVER="${ODOO_SMTP_SERVER:-localhost}"

# smtp_port (default 25)
export ODOO_SMTP_PORT="${ODOO_SMTP_PORT:-25}"

# smtp_ssl (default False)
export ODOO_SMTP_SSL="${ODOO_SMTP_SSL:-False}"

# smtp_user (default False)
export ODOO_SMTP_USER="${ODOO_SMTP_USER:-False}"

# smtp_password (default False)
export ODOO_SMTP_PASSWORD="${ODOO_SMTP_PASSWORD:-False}"

# smtp_ssl_certificate_filename (default False)
export ODOO_SMTP_SSL_CERTIFICATE_FILENAME="${ODOO_SMTP_SSL_CERTIFICATE_FILENAME:-False}"

# smtp_ssl_private_key_filename (default False)
export ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME="${ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME:-False}"


####
# Database related options
####

# db_name (default False)
export ODOO_DB_NAME="${ODOO_DB_NAME:-}"

# db_user (default False)
export ODOO_DB_USER="${ODOO_DB_USER:-}"

# db_password (default False)
export ODOO_DB_PASSWORD="${ODOO_DB_PASSWORD:-}"

# pg_path (default None)
export ODOO_PG_PATH="${ODOO_PG_PATH:-}"

# db_host (default False)
export ODOO_DB_HOST="${ODOO_DB_HOST:-}"

# db_replica_host (default False)
export ODOO_DB_REPLICA_HOST="${ODOO_DB_REPLICA_HOST:-}"

# db_port (default False)
export ODOO_DB_PORT="${ODOO_DB_PORT:-}"

# db_replica_port (default False)
export ODOO_DB_REPLICA_PORT="${ODOO_DB_REPLICA_PORT:-}"

# db_sslmode (default prefer)
export ODOO_DB_SSLMODE="${ODOO_DB_SSLMODE:-prefer}"

# db_maxconn (default 64)
export ODOO_DB_MAXCONN="${ODOO_DB_MAXCONN:-64}"

# db_maxconn_gevent (default False)
export ODOO_DB_MAXCONN_GEVENT="${ODOO_DB_MAXCONN_GEVENT:-}"

# db_template (default template0)
export ODOO_DB_TEMPLATE="${ODOO_DB_TEMPLATE:-template0}"


####
# Internationalisation options
####

# load_language (default None)
export ODOO_LOAD_LANGUAGE="${ODOO_LOAD_LANGUAGE:-}"

# language (default None)
export ODOO_LANGUAGE="${ODOO_LANGUAGE:-}"

# translate_out (default None)
export ODOO_TRANSLATE_OUT="${ODOO_TRANSLATE_OUT:-}"

# translate_in (default None)
export ODOO_TRANSLATE_IN="${ODOO_TRANSLATE_IN:-}"

# overwrite_existing_translations (default False)
export ODOO_OVERWRITE_EXISTING_TRANSLATIONS="${ODOO_OVERWRITE_EXISTING_TRANSLATIONS:-False}"

# translate_modules (default None)
export ODOO_TRANSLATE_MODULES="${ODOO_TRANSLATE_MODULES:-}"


####
# Security-related options
####

# list_db (default True)
export ODOO_LIST_DB="${ODOO_LIST_DB:-True}"


####
# Advanced options
####

# dev_mode (default None)
export ODOO_DEV_MODE="${ODOO_DEV_MODE:-}"

# shell_interface (default None)
export ODOO_SHELL_INTERFACE="${ODOO_SHELL_INTERFACE:-}"

# stop_after_init (default False)
export ODOO_STOP_AFTER_INIT="${ODOO_STOP_AFTER_INIT:-False}"

# osv_memory_count_limit (default 0)
export ODOO_OSV_MEMORY_COUNT_LIMIT="${ODOO_OSV_MEMORY_COUNT_LIMIT:-0}"

# transient_age_limit (default 1.0)
export ODOO_TRANSIENT_AGE_LIMIT="${ODOO_TRANSIENT_AGE_LIMIT:-1.0}"

# max_cron_threads (default 2)
export ODOO_MAX_CRON_THREADS="${ODOO_MAX_CRON_THREADS:-2}"

# limit_time_worker_cron (default 0)
export ODOO_LIMIT_TIME_WORKER_CRON="${ODOO_LIMIT_TIME_WORKER_CRON:-0}"

# unaccent (default False)
export ODOO_UNACCENT="${ODOO_UNACCENT:-False}"

# geoip_city_db (default /usr/share/GeoIP/GeoLite2-City.mmdb)
export ODOO_GEOIP_CITY_DB="${ODOO_GEOIP_CITY_DB:-/usr/share/GeoIP/GeoLite2-City.mmdb}"

# geoip_country_db (default /usr/share/GeoIP/GeoLite2-Country.mmdb)
export ODOO_GEOIP_COUNTRY_DB="${ODOO_GEOIP_COUNTRY_DB:-/usr/share/GeoIP/GeoLite2-Country.mmdb}"


####
# Multiprocessing options (POSIX only)
####

# workers (default 0)
export ODOO_WORKERS="${ODOO_WORKERS:-0}"

# limit_memory_soft (default 2147483648)
export ODOO_LIMIT_MEMORY_SOFT="${ODOO_LIMIT_MEMORY_SOFT:-2147483648}"

# limit_memory_soft_gevent (default False)
export ODOO_LIMIT_MEMORY_SOFT_GEVENT="${ODOO_LIMIT_MEMORY_SOFT_GEVENT:-}"

# limit_memory_hard (default 2684354560)
export ODOO_LIMIT_MEMORY_HARD="${ODOO_LIMIT_MEMORY_HARD:-2684354560}"

# limit_memory_hard_gevent (default False)
export ODOO_LIMIT_MEMORY_HARD_GEVENT="${ODOO_LIMIT_MEMORY_HARD_GEVENT:-}"

# limit_time_cpu (default 60)
export ODOO_LIMIT_TIME_CPU="${ODOO_LIMIT_TIME_CPU:-60}"

# limit_time_real (default 120)
export ODOO_LIMIT_TIME_REAL="${ODOO_LIMIT_TIME_REAL:-120}"

# limit_time_real_cron (default -1)
export ODOO_LIMIT_TIME_REAL_CRON="${ODOO_LIMIT_TIME_REAL_CRON:--1}"

# limit_request (default 65536)
export ODOO_LIMIT_REQUEST="${ODOO_LIMIT_REQUEST:-65536}"

# Set the password file environment variable
if [ -v PASSWORD_FILE ]; then
    DB_PASSWORD="$(< $PASSWORD_FILE)"
fi

ls -la /volumes/addons

# Substitute environment variables into the config file
# and write them back to the Odoo config
envsubst < /volumes/config/odoo.conf > "${ODOO_RC}"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py
            exec odoo "$@"
        fi
        ;;
    -*)
        wait-for-psql.py
        exec odoo "$@"
        ;;
    *)
        exec "$@"
esac

exit 1
