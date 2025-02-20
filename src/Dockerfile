ARG PYTHON_VERSION=3.12
ARG NODE_VERSION=22
ARG WKHTMLTOPDF_VERSION=3.21.2-0.12.6

FROM surnet/alpine-wkhtmltopdf:${WKHTMLTOPDF_VERSION}-full AS wkhtmltopdf

# Download the source from git
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


# Build the Python venv
FROM python:${PYTHON_VERSION}-alpine as venv

ARG TARGETARCH

RUN apk add --no-cache \
    build-base \
    libffi-dev \
    openssl-dev \
    libxml2-dev \
    postgresql-dev \
    libxslt-dev \
    openldap-dev \
    cairo-dev \
    pango-dev

RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Install front end dependencies
COPY --from=source /odoo/requirements.txt .

# Extra requirements and version pins per Odoo's runbot:
# https://runbot.odoo.com/runbot/dockerfile/tag/odoo:Docker18
RUN pip install --no-cache-dir ebaysdk==2.1.5 pdf417gen==0.7.1

# Install Odoo's requirements and the Odoo package
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Build front-end dependencies
FROM node:${NODE_VERSION}-alpine AS node

RUN npm install -g less less-plugin-clean-css rtlcss


# Run the code
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

# Add an 'odoo' user in Alpine
RUN addgroup -g 1000 odoo && \
    adduser -D -u 1000 -G odoo odoo

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
    envsubst \
    cairo \
    pango

# wkhtmltopdf copy bins from ext image
COPY --chown=odoo:odoo --from=wkhtmltopdf /bin/wkhtmltopdf /bin

# Copy the python venv with everything ready for Odoo
COPY --chown=odoo:odoo --from=venv /venv /venv

# Set the venv in the path, allowing applications to execute the odoo command
ENV PATH="/venv/bin:$PATH"

# copy node files from ext image
COPY --chown=odoo:odoo --from=node /usr/lib /usr/lib
COPY --chown=odoo:odoo --from=node /usr/local/lib /usr/local/lib
COPY --chown=odoo:odoo --from=node /usr/local/include /usr/local/include
COPY --chown=odoo:odoo --from=node /usr/local/bin /usr/local/bin

# Set the location of the input and output file for our config
ENV ODOO_CONFIG=/volumes/config/odoo.conf \
    ODOO_RC=/volumes/config/_generated.conf

# Supported Odoo config options.
# Fill these out to enable build-time defaults
ENV ODOO_CONFIG="/volumes/config/odoo.conf" \
    ODOO_DEFAULT_ADDONS="/odoo/addons" \
    ODOO_ADDONS_PATH="/odoo/addons,/volumes/addons" \
    ODOO_SAVE="False" \
    ODOO_INIT="" \
    ODOO_UPDATE="" \
    ODOO_WITHOUT_DEMO="False" \
    ODOO_IMPORT_PARTIAL="" \
    ODOO_PIDFILE="" \
    ODOO_UPGRADE_PATH="" \
    ODOO_SERVER_WIDE_MODULES="base,web" \
    ODOO_DATA_DIR="/volumes/data" \
    ODOO_HTTP_INTERFACE="" \
    ODOO_HTTP_PORT="8069" \
    ODOO_GEVENT_PORT="8072" \
    ODOO_HTTP_ENABLE="True" \
    ODOO_PROXY_MODE="False" \
    ODOO_X_SENDFILE="False" \
    ODOO_DBFILTER="" \
    ODOO_TEST_FILE="" \
    ODOO_TEST_ENABLE="" \
    ODOO_TEST_TAGS="" \
    ODOO_SCREENCASTS="" \
    ODOO_SCREENSHOTS="/tmp/odoo_tests" \
    ODOO_LOGFILE="" \
    ODOO_SYSLOG="" \
    ODOO_LOG_HANDLER=":INFO" \
    ODOO_LOG_DB="" \
    ODOO_LOG_DB_LEVEL="warning" \
    ODOO_LOG_LEVEL="info" \
    ODOO_EMAIL_FROM="" \
    ODOO_FROM_FILTER="" \
    ODOO_SMTP_SERVER="localhost" \
    ODOO_SMTP_PORT="25" \
    ODOO_SMTP_SSL="" \
    ODOO_SMTP_USER="" \
    ODOO_SMTP_PASSWORD="" \
    ODOO_SMTP_SSL_CERTIFICATE_FILENAME="" \
    ODOO_SMTP_SSL_PRIVATE_KEY_FILENAME="" \
    ODOO_DB_NAME="" \
    ODOO_DB_USER="" \
    ODOO_DB_PASSWORD="" \
    ODOO_PG_PATH="" \
    ODOO_DB_HOST="" \
    ODOO_DB_REPLICA_HOST="" \
    ODOO_DB_PORT="" \
    ODOO_DB_REPLICA_PORT="" \
    ODOO_DB_SSLMODE="prefer" \
    ODOO_DB_MAXCONN="64" \
    ODOO_DB_MAXCONN_GEVENT="" \
    ODOO_DB_TEMPLATE="template0" \
    ODOO_LOAD_LANGUAGE="" \
    ODOO_LANGUAGE="" \
    ODOO_TRANSLATE_OUT="" \
    ODOO_TRANSLATE_IN="" \
    ODOO_OVERWRITE_EXISTING_TRANSLATIONS="" \
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

# Create the data locations used by default, and create a default empty configuration file at _generated.conf
RUN mkdir odoo:odoo -p /volumes/config /volumes/data /volumes/addons \
    && echo "[options]" > /volumes/config/_generated.conf

# Set ownership of all related volumes to odoo:odoo
RUN chown -R odoo:odoo /volumes

# Expose the volumes to allow users to mount these folders directly
VOLUME ["/volumes/data", "/volumes/addons", "/volumes/config"]

# Copy the Odoo install
COPY --from=source /odoo .

# Install Odoo into the venv
#RUN pip install --no-cache-dir . \
#    && ln -s /odoo/addons /venv/lib/python3.12/site-packages/addons
RUN pip install --no-cache-dir .


# Switch to Odoo user
USER odoo

## Copy entrypoint + config
COPY entrypoint.sh /
COPY odoo.conf /volumes/config/odoo.conf

# Expose Odoo services
EXPOSE 8069 8071 8072

# Copy the wait-for-psql script
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Get things started
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]