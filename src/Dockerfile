ARG PYTHON_VERSION=3.12
ARG NODE_VERSION=22
ARG WKHTMLTOPDF_VERSION=3.21.2-0.12.6

FROM surnet/alpine-wkhtmltopdf:${WKHTMLTOPDF_VERSION}-small as wkhtmltopdf
FROM node:${NODE_VERSION}-alpine as node
FROM alpine:latest as source

ARG ODOO_VERSION=18.0
ARG BASE_URL="http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb"
ARG SOURCES_URL="http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/Sources"

RUN apk add --no-cache curl bash grep gawk coreutils xz

WORKDIR /odoo

# 1. Fetch "Sources" file
# 2. Extract line with .tar.xz and its SHA256
# 3. Download the tarball and verify against the checksum
# 4. Extract Odoo to /odoo/odoo
RUN set -eux; \
    # 1. Get the line from the Sources file
    line="$(curl -s "$SOURCES_URL" \
      | awk '/^Checksums-Sha256:/{f=1;next}/^Files:/{f=0}f' \
      | grep '.tar.xz')"; \
    # 2. Parse out SHA256, size, and filename using awk
    sha256="$(echo "$line" | awk '{print $1}')"; \
    size="$(echo "$line" | awk '{print $2}')"; \
    filename="$(echo "$line" | awk '{print $3}')"; \
    # 3. Download the file
    curl -fSL -o "odoo.tar.xz" "${BASE_URL}/${filename}"; \
    echo "$sha256  odoo.tar.xz" | sha256sum --check -; \
    # 5. Unpack it
    tar -xf "odoo.tar.xz" -C . --strip-components=1

RUN rm -rf odoo.tar.xz


FROM python:${PYTHON_VERSION}-alpine
MAINTAINER Adomi Software, LLC <github@adomisoftware.com>

WORKDIR /odoo

# Optional: busybox shell is default, but let's ensure we have bash for your scripts
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG=en_US.UTF-8

# Odoo environment
ENV ODOO_VERSION 18.0
ARG ODOO_RELEASE=20250207
ARG ODOO_SHA=5658df4949b61e3b910aaa1000ec2b14c2b565c9
ENV ODOO_RC /etc/odoo/odoo_docker.conf

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
    postgresql-client \
    font-noto-cjk \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    libxml2-dev \
    postgresql-dev \
    libxslt-dev \
    openldap-dev \
    build-base \
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

# Copy the Odoo install
COPY --from=source /odoo .

# Install Odoo's requirements and the Odoo package
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir .

## Copy entrypoint + config
COPY entrypoint.sh /
COPY odoo.conf /etc/odoo/odoo.conf

# Create the related files and folders for Odoo
RUN touch /etc/odoo/odoo_docker.conf && \
    chmod +x /entrypoint.sh && \
    chown odoo:odoo /etc/odoo/odoo.conf /etc/odoo/odoo_docker.conf && \
    mkdir -p /mnt/extra-addons && \
    chown -R odoo /mnt/extra-addons && \
    mkdir /var/lib/odoo && \
    chown -R odoo /var/lib/odoo

VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
