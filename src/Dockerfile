ARG PYTHON_VERSION=3.10
ARG NODE_VERSION=22
ARG WKHTMLTOPDF_VERSION=3.21.2-0.12.6

FROM surnet/alpine-wkhtmltopdf:${WKHTMLTOPDF_VERSION}-full AS wkhtmltopdf
FROM node:${NODE_VERSION}-alpine AS node

#FROM alpine:latest AS source
#
#ENV ODOO_VERSION=18.0
#ENV ODOO_REPOSITORY=https://github.com/odoo/odoo.git
#
#WORKDIR /odoo
#
#RUN apk add --no-cache curl bash grep gawk coreutils xz
#ARG BASE_URL="http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb"
##ARG SOURCES_URL="http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/Sources"
#
#RUN set -eux; \
#    # 1. Get the line from the Sources file
#    line="$(curl -s "$BASE_URL/Sources" \
#      | awk '/^Checksums-Sha256:/{f=1;next}/^Files:/{f=0}f' \
#      | grep '.tar.xz')"; \
#    # 2. Parse out SHA256, size, and filename using awk
#    sha256="$(echo "$line" | awk '{print $1}')"; \
#    size="$(echo "$line" | awk '{print $2}')"; \
#    filename="$(echo "$line" | awk '{print $3}')"; \
#    # 3. Download the file
#    curl -fSL -o "odoo.tar.xz" "${BASE_URL}/${filename}"; \
#    echo "$sha256  odoo.tar.xz" | sha256sum --check -; \
#    # 5. Unpack it
#    tar -xf "odoo.tar.xz" -C . --strip-components=1
#RUN rm -rf odoo.tar.xz

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
LABEL maintainer="Adomi Software, LLC <github@adomisoftware.com>"

WORKDIR /odoo

ENV LANG=en_US.UTF-8

# Set the location of the generated Odoo conf
ENV ODOO_RC=/etc/odoo/odoo_generated.conf

RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"

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
    cairo-dev \
    py3-cairo \
    envsubst \
    cyrus-sasl-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    zlib-dev

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
COPY test.sh /
COPY odoo.conf /volumes/config

# Create the related files and folders for Odoo
RUN mkdir odoo:odoo /etc/odoo && \
    touch /etc/odoo/odoo_generated.conf && \
    chmod +x /entrypoint.sh && \
    chown odoo:odoo /volumes/config /etc/odoo/odoo_generated.conf && \
    mkdir -p /volumes/addons && \
    chown -R odoo /volumes/addons && \
    mkdir /volumes/data && \
    chown -R odoo /volumes/data

VOLUME ["/volumes/data", "/volumes/addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
