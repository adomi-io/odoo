ARG PYTHON_VERSION=3.12
ARG NODE_VERSION=22
ARG WKHTMLTOPDF_VERSION=3.21.2-0.12.6

FROM surnet/alpine-wkhtmltopdf:${WKHTMLTOPDF_VERSION}-full AS wkhtmltopdf
FROM node:${NODE_VERSION}-alpine AS node
FROM alpine/git AS source

ENV ODOO_VERSION=18.0
ENV ODOO_REPOSITORY=https://github.com/odoo/odoo.git

WORKDIR /odoo

# Grab the latest source from GitHub
RUN git clone  \
    --branch ${ODOO_VERSION}  \
    --single-branch  \
    --depth 1  \
    ${ODOO_REPOSITORY} .

FROM python:${PYTHON_VERSION}-alpine

WORKDIR /odoo

ARG TARGETARCH

# Docker labels
LABEL source="odoo" \
      maintainer="Adomi Software, LLC <github@adomisoftware.com>" \
      uploaders="Adomi Software, LLC <github@adomisoftware.com>" \
      homepage="https://www.github.com/adomi-io/odoo" \
      vcs_git="https://www.github.com/adomi-io/odoo" \
      vcs_browser="https://www.github.com/adomi-io/odoo"

# Setup environment
ENV LANG=en_US.UTF-8

# Set the location of the generated Odoo conf
ENV ODOO_RC=/volumes/config/_generated.conf
ENV ODOO_CONFIG=/volumes/config/odoo.conf

# Supported Odoo config options
ENV ODOO_CONFIG="/volumes/config/odoo.conf" \
    ODOO_DEFAULT_ADDONS="/odoo/addons" \
    EXTRA_ADDONS="/volumes/addons" \
    ADDONS_PATH="/odoo/addons,/volumes/addons" \
    ODOO_SAVE="False" \
    ODOO_INIT="" \
    ODOO_UPDATE="" \
    ODOO_WITHOUT_DEMO="False" \
    ODOO_IMPORT_PARTIAL="" \
    ODOO_PIDFILE="" \
    ODOO_ADDONS_PATH="" \
    ODOO_UPGRADE_PATH="" \
    ODOO_SERVER_WIDE_MODULES="base,web" \
    ODOO_DATA_DIR="/var/lib/odoo" \
    ODOO_HTTP_INTERFACE="" \
    ODOO_HTTP_PORT="8069" \
    ODOO_GEVENT_PORT="8072" \
    ODOO_HTTP_ENABLE="True" \
    ODOO_PROXY_MODE="False" \
    ODOO_X_SENDFILE="False" \
    ODOO_DBFILTER="" \
    ODOO_TEST_FILE="False" \
    ODOO_TEST_ENABLE="" \
    ODOO_TEST_TAGS="" \
    ODOO_SCREENCASTS="" \
    ODOO_SCREENSHOTS="/tmp/odoo_tests" \
    ODOO_LOGFILE="" \
    ODOO_SYSLOG="False" \
    ODOO_LOG_HANDLER=":INFO" \
    ODOO_LOG_DB="False" \
    ODOO_LOG_DB_LEVEL="warning" \
    ODOO_LOG_LEVEL="info" \
    ODOO_EMAIL_FROM="False" \
    ODOO_FROM_FILTER="False" \
    ODOO_SMTP_SERVER="localhost" \
    ODOO_SMTP_PORT="25" \
    ODOO_SMTP_SSL="False" \
    ODOO_SMTP_USER="False" \
    ODOO_SMTP_PASSWORD="False" \
    ODOO_SMTP_SSL_CERTIFICATE_FILENAME="False" \
    ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME="False" \
    ODOO_DB_NAME="False" \
    ODOO_DB_USER="False" \
    ODOO_DB_PASSWORD="False" \
    ODOO_PG_PATH="" \
    ODOO_DB_HOST="False" \
    ODOO_DB_REPLICA_HOST="False" \
    ODOO_DB_PORT="False" \
    ODOO_DB_REPLICA_PORT="False" \
    ODOO_DB_SSLMODE="prefer" \
    ODOO_DB_MAXCONN="64" \
    ODOO_DB_MAXCONN_GEVENT="False" \
    ODOO_DB_TEMPLATE="template0" \
    ODOO_LOAD_LANGUAGE="" \
    ODOO_LANGUAGE="" \
    ODOO_TRANSLATE_OUT="" \
    ODOO_TRANSLATE_IN="" \
    ODOO_OVERWRITE_EXISTING_TRANSLATIONS="False" \
    ODOO_TRANSLATE_MODULES="" \
    ODOO_LIST_DB="True" \
    ODOO_DEV_MODE="" \
    ODOO_SHELL_INTERFACE="" \
    ODOO_STOP_AFTER_INIT="False" \
    ODOO_OSV_MEMORY_COUNT_LIMIT="0" \
    ODOO_TRANSIENT_AGE_LIMIT="1.0" \
    ODOO_MAX_CRON_THREADS="2" \
    ODOO_LIMIT_TIME_WORKER_CRON="0" \
    ODOO_UNACCENT="False" \
    ODOO_GEOIP_CITY_DB="/usr/share/GeoIP/GeoLite2-City.mmdb" \
    ODOO_GEOIP_COUNTRY_DB="/usr/share/GeoIP/GeoLite2-Country.mmdb" \
    ODOO_WORKERS="0" \
    ODOO_LIMIT_MEMORY_SOFT="2147483648" \
    ODOO_LIMIT_MEMORY_SOFT_GEVENT="False" \
    ODOO_LIMIT_MEMORY_HARD="2684354560" \
    ODOO_LIMIT_MEMORY_HARD_GEVENT="False" \
    ODOO_LIMIT_TIME_CPU="60" \
    ODOO_LIMIT_TIME_REAL="120" \
    ODOO_LIMIT_TIME_REAL_CRON="-1" \
    ODOO_LIMIT_REQUEST="65536"

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Add an 'odoo' user in Alpine
RUN addgroup -g 101 odoo && \
    adduser -D -u 101 -G odoo odoo

# Install dependencies:
RUN apk add --update --no-cache \
    bash \
    ca-certificates \
    curl \
    gnupg \
    ttf-dejavu \
    libx11 \
    libxrender \
    libxext \
    libxfixes \
    postgresql-client \
    font-noto-cjk \
    build-base \
    libffi-dev \
    openssl-dev \
    libxml2-dev \
    postgresql-dev \
    libxslt-dev \
    openldap-dev \
    envsubst

# wkhtmltopdf copy bins from ext image
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin

# copy node files from ext image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Install front end dependencies
RUN npm install -g less less-plugin-clean-css rtlcss
COPY --from=source /odoo/requirements.txt /odoo/requirements.txt

# Install Odoo's requirements and the Odoo package
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the Odoo install
COPY --from=source /odoo .
RUN pip install --no-cache-dir .

## Copy entrypoint + config
COPY entrypoint.sh /
COPY odoo.conf /volumes/config/odoo.conf

# Create the related files and folders for Odoo
RUN mkdir odoo:odoo /etc/odoo && \
    touch /etc/odoo/odoo_generated.conf && \
    chmod +x /entrypoint.sh && \
    chown odoo:odoo /volumes/config /etc/odoo/odoo_generated.conf && \
    mkdir -p /volumes/addons && \
    chown -R odoo /volumes/addons && \
    mkdir /volumes/data && \
    chown -R odoo /volumes/data

VOLUME ["/volumes/data", "/volumes/addons", "/volumes/secrets", "/volumes/config"]

# Expose Odoo services
EXPOSE 8069 8071 8072

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]