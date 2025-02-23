# Download the source code from a branch
# You can get the related corrisponding enterprise and design-themes versions by running
# from odoo import release; print(release.repos_heads)
FROM alpine/git AS source

ARG ODOO_VERSION=18.0
ARG ODOO_REPOSITORY=https://github.com/odoo/odoo.git

WORKDIR /source

# Grab the latest source from GitHub
RUN git clone  \
    --branch ${ODOO_VERSION}  \
    --single-branch  \
    --depth 1  \
    ${ODOO_REPOSITORY} .

# This build step will go download the latest version
# of wkhtmltopdf (keep your eyes on https://github.com/odoo/paper-muncher)
FROM alpine/curl as wkhtmltox

# Options to fetch WKHTMLTOPDF
ARG WKHTMLTOPDF_VERSION=0.12.6.1-3.jammy
ARG WKHTMLTOPDF_AMD64_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59
ARG WKHTMLTOPDF_ARM64_SHA=90f6e69896d51ef77339d3f3a20f8582bdf496cc
ARG WKHTMLTOPDF_PPC64EL_SHA=5312d7d34a25b321282929df82e3574319aed25c

# Get the build-type, amd64, arm64, ppc64le | ppc64el
ARG TARGETARCH

# This will be the output directory for this build step
WORKDIR /wkhtmltox

# This will get the target architecture and automate the download of
# wkhtmltopdf based on the builds target architecture, and confirm
# its validity based on its checksum
RUN if [ -z "${TARGETARCH}" ]; then \
        TARGETARCH="$(dpkg --print-architecture)"; \
    fi; \
    WKHTMLTOPDF_ARCH=${TARGETARCH} && \
    case ${TARGETARCH} in \
    "amd64") WKHTMLTOPDF_ARCH=amd64 && WKHTMLTOPDF_SHA=$WKHTMLTOPDF_AMD64_SHA  ;; \
    "arm64")  WKHTMLTOPDF_SHA=$WKHTMLTOPDF_ARM64_SHA  ;; \
    "ppc64le" | "ppc64el") WKHTMLTOPDF_ARCH=ppc64el && WKHTMLTOPDF_SHA=$WKHTMLTOPDF_PPC64EL_SHA  ;; \
    esac \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_${WKHTMLTOPDF_VERSION}_${WKHTMLTOPDF_ARCH}.deb \
    && echo ${WKHTMLTOPDF_SHA} wkhtmltox.deb | sha1sum -c -

# This will download the latest version of the
# MaxMind GeoLite2 country, city, and ASN databases
# which is used for IP Address geolocation
FROM alpine as geolite

ARG GEOLITE_GITHUB_REPOSITORY=P3TERX/GeoLite.mmdb

# Install required packages: curl, jq, and tar (or unzip if needed)
RUN apk add --no-cache curl jq tar

# Download the latest release assets from the r epository
RUN urls=$(curl -s https://api.github.com/repos/${GEOLITE_GITHUB_REPOSITORY}/releases/latest \
         | jq -r '.assets[].browser_download_url') \
 && for url in $urls; do \
      echo "Downloading $url..."; \
      curl -L "$url" -o "$(basename "$url")"; \
    done

#This build step will compile the Odoo source code into a .deb file
FROM ubuntu:noble as deb

# Install necessary build tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        devscripts \
        debhelper \
        python3 \
        python3-dev \
        python3-pip \
        libxml2-dev \
        libxslt1-dev \
        libldap2-dev \
        libsasl2-dev \
        libffi-dev \
        wget \
        dh-python \
        python3-asn1crypto \
        rsync \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set our initial directory to /build/src.
# When we build our .deb, the resulting
# build will be moved one directory higher
WORKDIR /build/src

# Copy the source code from the source-fetching image
COPY --from=source /source/odoo .

# Compile the Odoo .deb file
RUN dpkg-buildpackage -us -uc

# dpkg-buildpackage will produce files with some crazy names.
# This will grab whatever .deb file was output and move it to the
# /output directory, renaming it to odoo.deb for other build-steps to pick up
RUN mkdir /output && \
    mv /build/odoo*.deb /output/odoo.deb


# This is the final output, and is the container that will run our code
FROM ubuntu:noble

# Docker labels
LABEL source="Odoo" \
      maintainer="Adomi Software, LLC <github@adomisoftware.com>" \
      uploaders="Adomi Software, LLC <github@adomisoftware.com>" \
      homepage="https://www.github.com/adomi-io/odoo" \
      vcs_git="https://www.github.com/adomi-io/odoo" \
      vcs_browser="https://www.github.com/adomi-io/odoo"

# # Use /bin/bash with debugging (-x) and fail on pipeline errors (-o pipefail) for subsequent commands
SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# We will be downloading various packages through the build process.
# In order to avoid any bloat, we will use a setup directory.
# At the end of the build step, this directly should be empty and removed.
WORKDIR /setup

# Set our environment local
ENV LANG=C.UTF-8

# Set the location of the input and output file for our config.
# ODOO_RC is checked by Odoo in the config.py script
ENV ODOO_CONFIG=/volumes/config/odoo.conf \
    ODOO_RC=/volumes/config/_generated.conf

# ENV NODE_PATH=/usr/lib/node_modules/
ENV NODE_PATH=/usr/lib/node_modules/

# This will allow user-wide installation of packages
# This flag is used by npm and yarn
ENV npm_config_prefix=/usr

# Odoo-specific configuration options
# If you set these, these values are baked into the container.
# This means they will be the default if no other environment variable is specified at run-time.
ENV ODOO_CONFIG="/volumes/config/_generated.conf" \
    ODOO_ADDONS_PATH="/volumes/addons" \
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

# Install Odoo dependencies and system packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        libpq-dev \
        python3-dev \
        python3-venv \
        libldap2-dev \
        libsasl2-dev \
#        python3-magic \
#        python3-num2words \
#        python3-odf \
#        python3-pdfminer \
#        python3-pip \
#        python3-phonenumbers \
#        python3-pyldap \
#        python3-qrcode \
#        python3-renderpm \
#        python3-setuptools \
#        python3-slugify \
#        python3-vobject \
#        python3-watchdog \
#        python3-xlrd \
#        python3-xlwt \
        xz-utils \
        fontconfig \
        xfonts-75dpi \
        xfonts-base \
        libjpeg-turbo8 \
        libx11-6 \
        libxcb1 \
        libxext6 \
        libxrender1 \
        gettext && \
        rm -rf /var/lib/apt/lists/*

# Install the latest version of the Postgresql connector.
# The Ubuntu version can occasionally fall out of date, so we add the apt repository,
# per the postgresql docs: https://www.postgresql.org/download/linux/ubuntu/
RUN install -d /usr/share/postgresql-common/pgdg && \
    curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt noble-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt -y install postgresql && \
    rm -f /etc/apt/sources.list.d/pgdg.list && \
    rm -rf /var/lib/apt/lists/*

# Copy the wkhtmltopdf binary that we fetched in the wkhtmltox build step
COPY --from=wkhtmltox /wkhtmltox/wkhtmltox.deb wkhtmltox.deb

# Install the wkhtmltox.deb file we just copied, and then delete it
RUN apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install our Javascript dependencies
RUN npm install --force -g rtlcss@3.4.0

# Copy the deb file we compiled from source to the current image
#COPY --from=deb /output .

# Install the Odoo .deb file we copied, and then remove it
RUN apt-get update &&  \
    apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Create the data locations used by default, and create a default empty configuration file at _generated.conf
RUN mkdir -p /volumes/config /volumes/data /volumes/addons \
    && echo "[options]" > /volumes/config/_generated.conf

# Set the owner to user:group ubuntu:ubuntu
RUN chown -R ubuntu:ubuntu /volumes

# Expose the volumes to allow users to mount these folders directly
VOLUME ["/volumes/data", "/volumes/addons", "/volumes/config"]

# Create a virtualenv to install Odoo into
RUN python3 -m venv /app/venv

# Set the current directory to the Odoo folder
WORKDIR /odoo

# Copy the requirements.txt
COPY --from=source /source/odoo/requirements.txt requirements.txt

# Copy the code from the source-fetching container and copy it into the Odoo folder
COPY --from=source /odoo .

# Odoo's unit tests check to ensure that addons are located at
# /usr/lib/python3/dist-packages/addons.
# This is not setup automatically and must be created for unit tests to pass
RUN mkdir -p /usr/lib/python3/dist-packages/addons

# When Odoo is installed, it is installed into the odoo dist package:
# /usr/lib/python3/dist-packages/odoo.
# Odoo's unit tests expect there to be a dist-package installed called odoo-bin (test_upgrade_code.py)
# We can create a sym link so the unit tests pass
# This is a bit hacky but the same tests fail in the official container
RUN ln -s /odoo/odoo-bin /usr/lib/python3/dist-packages/odoo-bin

# Switch to Ubuntu user
# Note: Odoo uses UID and GID 101:101 in its .deb setup step.
# This creates problems generating files in a volume since
# Docker shares permissions on folders with the host machine.
# There really isnt any reason to use an Odoo user in this Docker container
# Ubuntu is gid 1000, and should match most host machines
USER ubuntu

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