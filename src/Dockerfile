# syntax=docker/dockerfile:1.9
# Download the source code from a branch
# You can get the related corrisponding enterprise and design-themes versions by running
# from odoo import release; print(release.repos_heads)
FROM alpine AS source

ARG ODOO_VERSION=19.0
ARG ODOO_REPOSITORY=https://github.com/odoo/odoo.git

# Install required packages: curl, jq, and tar (or unzip if needed)
RUN apk add --no-cache git ca-certificates && update-ca-certificates

# The source code will be stored in /source/odoo
WORKDIR /source

# Grab the latest source from GitHub
# We add a cache mount for git to speed up repeated builds
RUN --mount=type=cache,target=/root/.cache/git \
    git clone  \
    --branch ${ODOO_VERSION}  \
    --single-branch  \
    --depth 1  \
    ${ODOO_REPOSITORY}

# This build step will go download the latest version
# of wkhtmltopdf (keep your eyes on https://github.com/odoo/paper-muncher)
FROM alpine/curl AS wkhtmltox

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
RUN set -eu; \
    if [ -z "${TARGETARCH:-}" ]; then TARGETARCH="$(apk --print-arch)"; fi; \
    case "${TARGETARCH}" in \
      x86_64|amd64)    ARCH=amd64;   SHA=$WKHTMLTOPDF_AMD64_SHA ;; \
      aarch64|arm64)   ARCH=arm64;   SHA=$WKHTMLTOPDF_ARM64_SHA ;; \
      ppc64le|ppc64el) ARCH=ppc64el; SHA=$WKHTMLTOPDF_PPC64EL_SHA ;; \
      *) echo "Unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -sSL -o wkhtmltox.deb "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_${WKHTMLTOPDF_VERSION}_${ARCH}.deb"; \
    echo "${SHA}  wkhtmltox.deb" | sha1sum -c -

# This will download the latest version of the
# MaxMind GeoLite2 country, city, and ASN databases
# which is used for IP Address geolocation
FROM alpine AS geolite

ARG GEOLITE_GITHUB_REPOSITORY=P3TERX/GeoLite.mmdb

# Install required packages: curl, jq, and tar
RUN apk add --no-cache curl jq tar

WORKDIR /geolite

# Download the latest release assets from the repository
RUN urls=$(curl -s https://api.github.com/repos/${GEOLITE_GITHUB_REPOSITORY}/releases/latest \
         | jq -r '.assets[].browser_download_url') \
 && for url in $urls; do \
      echo "Downloading $url..."; \
      curl -L "$url" -o "$(basename "$url")"; \
    done

# This is the final output, and is the container that will run our code
FROM ubuntu:noble AS setup

# # Use /bin/bash with debugging (-x) and fail on pipeline errors (-o pipefail) for subsequent commands
# We also enable -e to exit on the first error and -u to catch unset vars
SHELL ["/bin/bash", "-xeuo", "pipefail", "-c"]

# Which version of Python to setup in the venv
ARG PYTHON_VERSION=3.13

# Non-root user and group for better security on hosts with mounted volumes
ARG UID=1000
ARG GID=1000

# We will be downloading various packages through the build process.
# In order to avoid any bloat, we will use a setup directory.
# At the end of the build step, this directly should be empty and removed.
WORKDIR /setup

# Set our environment local
ENV LANG=C.UTF-8

# Set the location of the input and output file for our config.
# ODOO_RC is checked by Odoo in the config.py script
ENV ODOO_RC=/volumes/config/_generated.conf \
    IMAGE_CONFIG_LOCATION=/volumes/config/odoo.conf

# ENV NODE_PATH=/usr/lib/node_modules/
ENV NODE_PATH=/usr/lib/node_modules/

# This will allow user-wide installation of packages
# This flag is used by npm and yarn
ENV npm_config_prefix=/usr

# Install Odoo dependencies and system packages
# We add tini as PID 1 to correctly handle signals and reap zombies.
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
        libldap2-dev \
        libsasl2-dev \
        xz-utils \
        fontconfig \
        xfonts-75dpi \
        xfonts-base \
        libjpeg-turbo8 \
        libx11-6 \
        libxcb1 \
        libxext6 \
        libxrender1 \
        gettext \
        postgresql-client \
        libcairo2-dev libcairo2 \
        git \
        tini; \
    rm -rf /var/lib/apt/lists/*

# Copy the wkhtmltopdf binary that we fetched in the wkhtmltox build step
COPY --from=wkhtmltox /wkhtmltox/wkhtmltox.deb wkhtmltox.deb

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update; \
    apt-get install -y --no-install-recommends ./wkhtmltox.deb; \
    rm -rf /var/lib/apt/lists/* /setup/wkhtmltox.deb

# Copy the geolite databases that we fetched in the geolite step
COPY --from=geolite /geolite /usr/share/GeoIP

# Install our Javascript dependencies
RUN npm install --force -g rtlcss@3.4.0

# Create the data locations used by default, and create a default empty configuration file at _generated.conf
RUN mkdir -p /volumes/config /volumes/data /volumes/addons \
    && echo "[options]" > /volumes/config/_generated.conf

# The /venv folder will house our Python virtual environment
WORKDIR /venv

# Install and setup Python. This uses the deadsnakes/ppa repository, which allows you to pull and test
# future releases of Python if you want.
RUN --mount=type=cache,target=/var/cache/apt \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update; \
  apt-get install -y --no-install-recommends gnupg software-properties-common ca-certificates; \
  add-apt-repository -y ppa:deadsnakes/ppa; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
       "python${PYTHON_VERSION}" "python${PYTHON_VERSION}-venv" "python${PYTHON_VERSION}-dev" \
       libxml2-dev libxslt1-dev zlib1g-dev libjpeg-dev libfreetype6-dev; \
  python${PYTHON_VERSION} -m venv /venv; \
  /venv/bin/python -m ensurepip --upgrade; \
  rm -rf /var/lib/apt/lists/*

ENV PATH="/venv/bin:${PATH}"

WORKDIR /setup

# Copy and install deps using the venv
COPY --from=source /source/odoo/requirements.txt requirements.txt

# Install the Odoo requirements
# We cache pip to speed rebuilds
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Install some additional addons required by Odoo
RUN pip install rlpycairo

# Odoo's unit tests check to ensure that addons are located at
# /usr/lib/python3/dist-packages/addons.
# This is not setup automatically and must be created for unit tests to pass
RUN mkdir -p "/venv/lib/python${PYTHON_VERSION}/site-packages/addons"

# This is the final container that will run the Odoo process
FROM setup

# Expose the volumes to allow users to mount these folders directly
VOLUME ["/volumes/data", "/volumes/addons", "/volumes/config", "/volumes/enterprise", "/volumes/extra_addons"]

# Docker labels
LABEL maintainer="Adomi Software, LLC <github@adomisoftware.com>" \
      uploaders="Adomi Software, LLC <github@adomisoftware.com>" \
      homepage="https://www.github.com/adomi-io/odoo" \
      vcs_git="https://www.github.com/adomi-io/odoo" \
      vcs_browser="https://www.github.com/adomi-io/odoo" \
      source="https://github.com/adomi-io/odoo" \
      description="Adomi-io - Odoo"

# # Use /bin/bash with debugging (-x) and fail on pipeline errors (-o pipefail) for subsequent commands
SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Odoo-specific configuration options
# If you set these, these values are baked into the container.
# This means they will be the default if no other environment variable is specified at run-time.
ENV ODOO_CONFIG="/volumes/config/_generated.conf" \
    ODOO_ADDONS_PATH="/odoo/addons,/volumes/addons" \
    ODOO_GEOIP_CITY_DB="/usr/share/GeoIP/GeoLite2-City.mmdb" \
    ODOO_GEOIP_COUNTRY_DB="/usr/share/GeoIP/GeoLite2-Country.mmdb" \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Set the current directory to the Odoo folder.
# This contains the source-code to Odoo
WORKDIR /odoo

# Copy the code from the source-fetching container and copy it into the Odoo folder
COPY --from=source /source/odoo/ .

# Install Odoo into the venv
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir .


# Odoo requires pypdf2<3.0. PyPDF2 is deprecated, and there is work in the upstream to fix this
RUN pip install "pypdf2<3.0"


# Add odoo-bin to the global applications
RUN chmod +x /odoo/odoo-bin \
 && ln -sf /odoo/odoo-bin /usr/local/bin/odoo-bin \
 && ln -sf /venv/bin/odoo /usr/local/bin/odoo

# When Odoo is installed, it is installed into the odoo dist package:
# /venv/lib/python3/site-packages/odoo.
# Odoo's unit tests expect there to be a site-package installed called odoo-bin (test_upgrade_code.py)
# We can create a sym link from our source directory to odoo-bin
RUN ln -s /odoo/odoo-bin "/venv/lib/python${PYTHON_VERSION}/site-packages/odoo-bin"

# Copy the odoo config into the default location
COPY odoo.conf /volumes/config/odoo.conf

# Copy the entrypoint into the container.
# The entry point is the script that runs when the Docker container is spun up
COPY entrypoint.sh /

# Copy the default hook setup script into the container. This script
# is ran after the entrypoint has parsed all the environment variables and secrets
# and generated the odoo configuration file but has not yet started Odoo.
# This lets a developer hook into the pre-launch process
# and have all the processed data at their disposal
COPY hook_setup /

# The wait-for-psql script waits for Postgres to start accepting connections
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the work directory to volumes directory where all of our Odoo data is stored
WORKDIR /volumes

# Create a non-root user for better isolation; we chown only the writable mounts
RUN set -eux; \
    chown -R "${UID}:${GID}" /volumes || true

# Add a healthcheck that pings Odoo's health endpoint; this helps orchestrators know when the app is ready
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD curl -fsS "http://127.0.0.1:${ODOO_HTTP_PORT:-8069}/web/health" || exit 1

# Set the user
USER ${UID:-1000}:${GID:-1000}

# Get things started
# We run through tini to properly handle signals and PID 1 semantics
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/entrypoint.sh"]

# Run the Odoo command
CMD ["odoo-bin"]
