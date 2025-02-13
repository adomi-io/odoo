ARG PYTHON_VERSION=3.12
ARG NODE_VERSION=22
ARG WKHTMLTOPDF_VERSION=3.21.2-0.12.6

FROM surnet/alpine-wkhtmltopdf:${WKHTMLTOPDF_VERSION}-full as wkhtmltopdf
FROM node:${NODE_VERSION}-alpine as node
FROM alpine/git as source

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
MAINTAINER Adomi Software, LLC <github@adomisoftware.com>

WORKDIR /odoo

ENV LANG=en_US.UTF-8

# Set the location of the generated Odoo conf
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
COPY odoo.conf /etc/odoo/odoo.conf

# Create the related files and folders for Odoo
RUN touch /etc/odoo/odoo_docker.conf && \
    chmod +x /entrypoint.sh && \
    chown odoo:odoo /etc/odoo/odoo.conf /etc/odoo/odoo_docker.conf && \
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
