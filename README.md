# Adomi-io - Odoo

This is an Odoo Docker container that is made for developers or infrastructure teams who are looking
to launch Odoo into the cloud, companies who want a reliable and open build process, or startups looking
to offer Odoo as part of a SaaS or IaaS product.

Odoo configuration is generated through environment variables, making it
simple to customize your setup without modifying your base image, automate deployments, 
and scale your Odoo instances effortlessly.

This repository mirrors the latest code from the official [Odoo GitHub repository](https://github.com/odoo/odoo) and is built nightly,
ensuring you always run the most up-to-date version for your specific Odoo release.

## Features

- 🔧 **Flexible Configuration:** Customize your Odoo instance with environment variables and secret files, no rebuilds needed.
- 🚀 **Cloud Native:** Configure your Odoo containers from Amazon ECS, Kubernetes, Digital Ocean, or other cloud providers easily.
- 🏗️ **Multi-Tenant Ready:** Built for SaaS and IaaS companies looking to support multiple Odoo tenants. Support any Odoo configuration option easily.
- 🤝 **Community Driven:** Built and maintained by the community, ensuring continuous improvements and real-world usability.


## Table of Contents

- [Getting Started](#getting-started) 
- [Run This Container](#run-this-container)
  - [Docker](#docker)
  - [Docker Compose](#docker-compose)

## Getting started

Pull the latest nightly build for your version of Odoo (e.g., 18.0):

```bash
docker pull ghcr.io/adomi-io/odoo:18.0
```

#### Supported versions


| Odoo                                               | Pull Command                                 |
|----------------------------------------------------|----------------------------------------------|
| [18.0](https://github.com/adomi-io/odoo/tree/18.0) | ```docker pull ghcr.io/adomi-io/odoo:18.0``` |
| [17.0](https://github.com/adomi-io/odoo/tree/17.0) | ```docker pull ghcr.io/adomi-io/odoo:17.0``` |
| [16.0](https://github.com/adomi-io/odoo/tree/16.0) | ```docker pull ghcr.io/adomi-io/odoo:16.0``` |

## Run this container

### Docker

#### Start a `Postgres` container

```bash
docker run -d \
  --name odoo_db \
  -e POSTGRES_USER=odoo \
  -e POSTGRES_PASSWORD=odoo \
  -e POSTGRES_DB=postgres \
  -p 5432:5432 \
  postgres:13
```
#### Start an `Odoo` container
```bash
docker run --name odoo \
  -p 8069:8069 \
  -e ODOO_DB_HOST=odoo_db \
  -e ODOO_DB_PORT=5432 \
  -e ODOO_DB_USER=odoo \
  -e ODOO_DB_PASSWORD=odoo \
  ghcr.io/adomi-io/odoo:18.0
```

### Docker Compose

This Docker Compose file will launch a copy of Odoo along with a Postgres database.

```yaml
version: '3.8'
services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    ports:
      - "8069:8069"
    environment:
      ODOO_DB_HOST: ${ODOO_DB_HOST:-db}
      ODOO_DB_PORT: ${ODOO_DB_PORT:-5432}
      ODOO_DB_USER: ${ODOO_DB_USER:-odoo}
      ODOO_DB_PASSWORD: ${ODOO_DB_PASSWORD:-odoo}
    volumes:
      - odoo_data:/volumes/data
      - ./addons:/volumes/addons
    depends_on:
      - db

  db:
    image: postgres:13
    container_name: odoo_db
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-odoo}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-odoo}
      POSTGRES_DB: ${POSTGRES_DATABASE:-postgres}
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  odoo_data:
  pg_data:
```

# Mounting Addons

## Mounting your addons

## Mounting OCA addons

## Mounting Enterprise

# Configure your Odoo instances

This Docker container uses `envsubst` to generate an `odoo.conf` file based on  environment variables. What this means is you can configure your Odoo configuration at all stages of the image's lifecycle. 
You can build values into your own docker container, set them at run-time via a mounted file, or defer those values to environment variables which you configure in your cloud providers UI.

This documentation will take you through configuring your Odoo instances

## Basic Example

How to mount a configuration file into the container

### Step 1: Create an `odoo.conf` file

Create a file in your projects folder called `odoo.conf`. We recommend copying the [default odoo.conf file provided with this image](./src/odoo.conf).

Modify it with the values you want to use. 

For example:
```ini
[options]
# Hard-code a value by entering the config name
db_host = my-hardcoded-database.abc-corp.com
workers = 2

# Defer to the environment variable by using the name of the config prefixed with ODOO_
db_port = $ODOO_DB_PORT
db_user = $ODOO_DB_USER
db_password = $ODOO_DB_PASSWORD
addons_path = $ODOO_ADDONS_PATH
data_dir = $ODOO_DATA_DIR
```

### Step 2: Mount the Configuration File

#### Docker

Add the `-v $(pwd)/odoo.conf:/volumes/config/odoo.conf` flag to your `docker run` command. Eg:

```
docker run -d \
  --name odoo \
  -p 8069:8069 \
  -v $(pwd)/odoo.conf:/volumes/config/odoo.conf \
  ghcr.io/adomi-io/odoo:18.0
```

#### Docker Compose

To use your custom configuration file, update your docker-compose.yml
to mount it to `/volumes/config/odoo.conf`:

```yaml
version: '3.8'
services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    # ...
    volumes:
      - ./odoo.conf:/volumes/config/odoo.conf # Add this to your docker compose configuration
```

## Default Odoo Configuration File
This image includes a default Odoo configuration, which you can override, modify, or hardcode as needed.

The configuration file is located [here](./src/odoo.conf) and is stored in the container at `/volumes/config/odoo.conf`.

Some configuration options, when set, alter Odoo’s default behavior. To maintain flexibility, many supported options are
included but are commented out by default.

For details on extending this image, see the [Extending this image](#extending-this-image) section.


These options are enabled by default, and can be set via environment variables:
```ini
[options]
# Database related options

# specify the database user name (default: False)
db_user = $ODOO_DB_USER

# specify the database password (default: False)
db_password = $ODOO_DB_PASSWORD

# specify the database host (default: False)
db_host = $ODOO_DB_HOST

# specify the database name (default: False)
db_name = $ODOO_DB_NAME

# specify the database port (default: False)
db_port = $ODOO_DB_PORT

# Common options

# Comma-separated list of server-wide modules. (default: base,web)
server_wide_modules = $ODOO_SERVER_WIDE_MODULES

# Directory where to store Odoo data (default: /var/lib/odoo)
data_dir = $ODOO_DATA_DIR

# specify additional addons paths (separated by commas). (default: None)
addons_path = $ODOO_ADDONS_PATH

# disable loading demo data for modules to be installed (comma-separated, use "all" for all modules). Requires -d and -i. Default is %default (default: False)
without_demo = $ODOO_WITHOUT_DEMO
```

## Debugging the generated config

The `odoo.conf` file is ran through `envsubst` and output to `/volumes/config/_generated.conf`.

If you need to see the final results, you can mount to the `/volumes/config` folder.

Move your config file in your project to `./config/odoo.conf`

Mount the `./config` folder this time instead, eg:

```yaml
version: '3.8'
services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    # ...
    volumes:
      - ./config:/volumes/config # This will mount your config folder into the container
```

When the container starts, you will see a `_generated.conf` file appear in the `config` folder which contains the final
configuration used by Odoo


# Extending this image

This image is based on Alpine Linux. This is a light-weight distribution of Linux that removes a lot of extra bloat.

Extending this image will allow you to create your own image, set default environment variables, and bake
your own config in as a default.

Create a new Dockerfile in your project

```dockerfile
FROM ghcr.io/adomi-io/odoo:18.0

# Copy your config file into the container
COPY odoo.conf /volumes/config/odoo.conf

# Copy your code into the addons folder
COPY . /volumes/addons
```

## Setting default variables

You can set the default value for the environment variables at build-time.

Copy the [odoo.conf](./src/odoo.conf). Uncomment or set the configuration options you'd like to support.

Setting the default with `ENV` will set that value if no environment value is passed into the container.

This lets you set a default, and override it from the environment variables or your cloud providers UI at run-time.

```dockerfile
FROM ghcr.io/adomi-io/odoo:18.0

# Copy your config into the image
COPY odoo.conf /volumes/config/odoo.conf

# Set the default value for subsequent images. 
ENV ODOO_WORKERS=5

# Copy your code into the addons folder
COPY . /volumes/addons
```

## Environment variable defaults


The Dockerfile is built with default environment variables. If you do not override
the environment variables when deploying your Odoo container,

Double check the [Dockerfile](./src/Dockerfile) for more information

```dockerfile

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
```

## Adding New Environment Variables

To add a new configuration variable:

1. **Set the Variable:** Add it to your environment (e.g., in your Docker Compose file, ECS task definition, or
   Kubernetes manifest).
2. **Update the Configuration:** Insert a placeholder for it in `odoo.conf`. For instance, if you add `MY_CUSTOM_VAR`,
   include:
   ```ini
   my_custom_setting = $MY_CUSTOM_VAR
   ```
3. **Deploy:** On container startup, the placeholder is replaced with the value from your environment.

# Testing your code

## Unit Testing with Environment Variables

This docker container supports the testing flags as environment variables.

You can build a custom Dockerimage dedicated to testing your code by extending this image


# Maintaining this repository

## Adding a new version of Odoo
When Odoo launches a new version, they publish the changes on its own branch. 
This repository works by mirroring the Odoo version branch names. 

When a new version of Odoo releases, create a branch in this repository with the same name.

Add the branch name to the [.github/workflows/docker-publish.yml](./.github/workflows/docker-publish.yml) 
file under `push` and `pull_request` branches.

The resulting image will automatically be built, unit-tested, deployed, and scheduled for update.

## Repository unit tests

The testing script is located in [./tests/unit-tests.sh](./tests/unit-tests.sh)

This will create a Postgres database, install all the selected Odoo addons,
and run their corresponding unit tests.

To run these tests, clone the repository:

`git@github.com:adomi-io/odoo.git`

`cd` into the cloned repository

`cd odoo`

From the root folder, run the unit test script

`./tests/unit-tests.sh`


## Custom Tests

You can run unit tests with the docker compose file. This will spin up a Postgres
database, install the addons of your choice, and run their corresponding unit tests.

For example, this will use a database named testing, install base and web, and run their unit tests:

```yml
docker compose run --rm odoo -- \
    -d testing \
    --update=base,web \
    --stop-after-init \
    --test-enable
```

# License

For license details, see the [LICENSE](https://github.com/adomi-io/odoo/blob/master/LICENSE) file in the repository.

