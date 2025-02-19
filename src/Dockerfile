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

# Set the location of the generated Odoo conf
ENV ODOO_RC=/volumes/config/_generated.conf
ENV ODOO_CONFIG=/volumes/config/odoo.conf

# Supported Odoo config options.
# Fill these out to enable build-time defaults
ENV ODOO_DATA_DIR="/volumes/data" \
    ADDONS_PATH="/odoo/addons,/volumes/addons" \
    ODOO_CONFIG="/volumes/config/odoo.conf" \
    ODOO_DB_USER="odoo" \
    ODOO_DB_PASSWORD="odoo" \
    ODOO_DB_HOST="db" \
    ODOO_DB_PORT="5432" \
    ODOO_DB_NAME="" \
    ODOO_DB_REPLICA_HOST="" \
    ODOO_DB_REPLICA_PORT="" \
    ODOO_DB_SSLMODE="" \
    ODOO_DB_MAXCONN="" \
    ODOO_DB_MAXCONN_GEVENT="" \
    ODOO_DB_TEMPLATE="" \
    ODOO_PG_PATH="" \
    ODOO_SAVE="" \
    ODOO_INIT="" \
    ODOO_UPDATE="" \
    ODOO_WITHOUT_DEMO="" \
    ODOO_IMPORT_PARTIAL="" \
    ODOO_PIDFILE="" \
    ODOO_ADDONS_PATH="" \
    ODOO_UPGRADE_PATH="" \
    ODOO_SERVER_WIDE_MODULES="" \
    ODOO_HTTP_INTERFACE="" \
    ODOO_HTTP_PORT="" \
    ODOO_GEVENT_PORT="" \
    ODOO_HTTP_ENABLE="" \
    ODOO_PROXY_MODE="" \
    ODOO_X_SENDFILE="" \
    ODOO_DBFILTER="" \
    ODOO_TEST_FILE="" \
    ODOO_TEST_ENABLE="" \
    ODOO_TEST_TAGS="" \
    ODOO_SCREENCASTS="" \
    ODOO_SCREENSHOTS="" \
    ODOO_LOGFILE="" \
    ODOO_SYSLOG="" \
    ODOO_LOG_HANDLER="" \
    ODOO_LOG_DB="" \
    ODOO_LOG_DB_LEVEL="" \
    ODOO_LOG_LEVEL="" \
    ODOO_EMAIL_FROM="" \
    ODOO_FROM_FILTER="" \
    ODOO_SMTP_SERVER="" \
    ODOO_SMTP_PORT="" \
    ODOO_SMTP_SSL="" \
    ODOO_SMTP_USER="" \
    ODOO_SMTP_PASSWORD="" \
    ODOO_SMTP_SSL_CERTIFICATE_FILENAME="" \
    ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME="" \
    ODOO_LOAD_LANGUAGE="" \
    ODOO_LANGUAGE="" \
    ODOO_TRANSLATE_OUT="" \
    ODOO_TRANSLATE_IN="" \
    ODOO_OVERWRITE_EXISTING_TRANSLATIONS="" \
    ODOO_TRANSLATE_MODULES="" \
    ODOO_LIST_DB="" \
    ODOO_DEV_MODE="" \
    ODOO_SHELL_INTERFACE="" \
    ODOO_STOP_AFTER_INIT="" \
    ODOO_OSV_MEMORY_COUNT_LIMIT="" \
    ODOO_TRANSIENT_AGE_LIMIT="" \
    ODOO_MAX_CRON_THREADS="" \
    ODOO_LIMIT_TIME_WORKER_CRON="0" \
    ODOO_UNACCENT="" \
    ODOO_GEOIP_CITY_DB="" \
    ODOO_GEOIP_COUNTRY_DB="" \
    ODOO_WORKERS="" \
    ODOO_LIMIT_MEMORY_SOFT="" \
    ODOO_LIMIT_MEMORY_SOFT_GEVENT="" \
    ODOO_LIMIT_MEMORY_HARD="" \
    ODOO_LIMIT_MEMORY_HARD_GEVENT="" \
    ODOO_LIMIT_TIME_CPU="" \
    ODOO_LIMIT_TIME_REAL="" \
    ODOO_LIMIT_TIME_REAL_CRON="" \
    ODOO_LIMIT_REQUEST=""

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

# Create volumes
VOLUME ["/volumes/data", "/volumes/addons", "/volumes/config"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Copy the wait-for-psql script
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Switch to Odoo user
USER odoo

# Get things started
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]