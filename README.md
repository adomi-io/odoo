# Adomi-io - Odoo

This is an Odoo Docker container that is made for developers or infrastructure teams who are looking
to launch Odoo into the cloud, companies who want a reliable and open build process, or startups looking
to offer Odoo as part of a SaaS or IaaS offering.

Odoo Configuration is generated through environment variables, making it
simple to customize your setup without modifying your base image, automate deployments, 
and scale your Odoo instances effortlessly.

This repository mirrors the latest code from the official [Odoo GitHub repository](https://github.com/odoo/odoo) and is built nightly,
ensuring you always run the most up-to-date version for your specific Odoo release.

Features
---

- 🔧 **Flexible Configuration:** Customize your Odoo instance with environment variables and secret files, no rebuilds needed.
- 🚀 **Cloud Native:** Configure your Odoo containers from Amazon ECS, Kubernetes, Digital Ocean, or other cloud providers easily.
- 🏗️ **Multi-Tenant Ready:** Built for SaaS and IaaS companies looking to support multiple Odoo tenants. Support any Odoo configuration option easily.
- 🤝 **Community Driven:** Built and maintained by the community, ensuring continuous improvements and real-world usability.


Table of Contents
---

- [Getting Started](#getting-started) 
- [Run This Container](#run-this-container)
  - [Docker](#docker)
  - [Docker Compose](#docker-compose)

---

# Getting started

Pull the latest nightly build for your version of Odoo (e.g., 18.0):

```bash
docker pull ghcr.io/adomi-io/odoo:18.0
```

Supported versions
---

| Odoo                                               | Pull Command                                 |
|----------------------------------------------------|----------------------------------------------|
| [18.0](https://github.com/adomi-io/odoo/tree/18.0) | ```docker pull ghcr.io/adomi-io/odoo:18.0``` |
| [17.0](https://github.com/adomi-io/odoo/tree/17.0) | ```docker pull ghcr.io/adomi-io/odoo:17.0``` |
| [16.0](https://github.com/adomi-io/odoo/tree/16.0) | ```docker pull ghcr.io/adomi-io/odoo:16.0``` |

# Run this container

Docker
---

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

Docker Compose
---
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

---

# Configure Odoo

## Mount a configuration file

By default, this image generates an Odoo configuration dynamically using environment variables.
However, you can mount a custom `odoo.conf` file to override settings directly.

### Step 1: Create or Update `odoo.conf`

Modify or create a new `odoo.conf` file with your custom settings. For example:

```ini
[options]
db_host = db
db_port = $DB_PORT
db_user = $DB_USER
db_password = odoo
admin_passwd = my_secure_admin_password
workers = 2
```

### Step 2: Mount the Configuration File

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

#### Docker

Add the `-v $(pwd)/odoo.conf:/volumes/config/odoo.conf` flag to your `docker run` command. Eg:

```
docker run -d \
  --name odoo \
  -p 8069:8069 \
  -v $(pwd)/odoo.conf:/volumes/config/odoo.conf \
  ghcr.io/adomi-io/odoo:18.0
```

# Configure your Odoo instances

Default Odoo Configuration File
---
This image includes a default Odoo configuration, which you can override, modify, or hardcode as needed.

The configuration file is located at `/volumes/config/odoo.conf`.

Some configuration options, when set, alter Odoo’s default behavior. To maintain flexibility, many supported options are
included but are commented out by default.

For details on extending this image, see the [Extending this image](#extending-this-image) section.

```.conf
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

# specify alternate config file (default: None)
config = $ODOO_CONFIG

# Comma-separated list of server-wide modules. (default: base,web)
server_wide_modules = $ODOO_SERVER_WIDE_MODULES

# Directory where to store Odoo data (default: /var/lib/odoo)
data_dir = $ODOO_DATA_DIR

# specify additional addons paths (separated by commas). (default: None)
addons_path = $ODOO_ADDONS_PATH

# disable loading demo data for modules to be installed (comma-separated, use "all" for all modules). Requires -d and -i. Default is %default (default: False)
without_demo = $ODOO_WITHOUT_DEMO
```

# Extending this image

Setting default variables
---
If you would like pull a `config` item from your environment variables, but use
a default across all your images, you can override the

Adding New Environment Variables
---

To add a new configuration variable:

1. **Set the Variable:** Add it to your environment (e.g., in your Docker Compose file, ECS task definition, or
   Kubernetes manifest).
2. **Update the Configuration:** Insert a placeholder for it in `odoo.conf`. For instance, if you add `MY_CUSTOM_VAR`,
   include:
   ```ini
   my_custom_setting = $MY_CUSTOM_VAR
   ```
3. **Deploy:** On container startup, the placeholder is replaced with the value from your environment.

Environment variable defaults
---

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

# Testing your code

Unit Testing with Environment Variables
---

This docker container supports the testing flags as environment variables.

You can build a custom Dockerimage dedicated to testing your code by extending this image



# Maintaining this repository

Odoo unit tests
---
The testing script is located in [./tests/unit-tests.sh](./tests/unit-tests.sh)

This will create a Postgres database, install all the selected Odoo addons,
and run their corresponding unit tests.

To run these tests, clone the repository:

`git@github.com:adomi-io/odoo.git`

`cd` into the cloned repository

`cd odoo`

From the root folder, run the unit test script

`./tests/unit-tests.sh`


Unit testing with Docker Compose
---

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


License
---

For license details, see the [LICENSE](https://github.com/adomi-io/odoo/blob/master/LICENSE) file in the repository.

