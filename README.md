<p align="center">
    <img src="static/repo_header_final.png" width="580" />
</p>


# Adomi-io - Odoo

Adomi is an Odoo partner and consulting company. We integrate Odoo into our development process to deliver efficient and scalable ERP solutions.

Our Docker image for Odoo is designed with speed, reliability, and flexibility in mind—providing a production-ready alternative that has been refined by our experienced team. 
While this isn't the official Odoo Docker container, it offers a robust and optimized solution for your deployment needs.

For those seeking the official container, please visit [odoo/docker](https://github.com/odoo/docker).

# Why a Different Container?

This container is built for developers, infrastructure teams, and companies looking to deploy Odoo on cloud platforms or offer Odoo as part of a SaaS/IaaS solution.

Using `envsubst` with environment variables, the container generates your Odoo configuration on the fly. This lets you customize your setup without modifying the base image, streamlining deployments and scaling your instances effortlessly.

Features include:
- [Simple deployments of Odoo Enterprise](#extending-this-image-with-odoo-enterprise)
- [Powerful extension options](#extending-this-image)
- A well-documented multi-stage [Dockerfile](./src/Dockerfile)
- An open, automated build process via [GitHub Actions](./.github/workflows/docker-publish.yml)
- Robust, open unit testing ([tests/unit-tests.sh](./tests/unit-tests.sh))

Built nightly from the latest code in the official [Odoo GitHub repository](https://github.com/odoo/odoo), 
this container ensures you’re always running the most up-to-date version of Odoo.


## 🚀 Key Features at a Glance

- 🔧 **Flexible Configuration:** Tweak your Odoo instance on the fly with environment variables and secret files—no rebuilds needed.
- ☁️ **Cloud Native:** Seamlessly deploy across Amazon ECS, Kubernetes, Digital Ocean, and more.
- 🏢 **Multi-Tenant Ready:** Perfect for SaaS/IaaS setups looking to support multiple Odoo tenants effortlessly.
- 🔄 **Nightly Builds:** Stay current with the latest code pulled directly from the official Odoo GitHub repository.
- 🧪 **Robust Testing:** Benefit from open, reliable unit tests that keep your deployments running smoothly.
- 🛠️ **Easy Extension:** Quickly extend the container to integrate Odoo Enterprise or your custom modules.
- ⚙️ **Optimized Build Process:** Enjoy a transparent, automated build pipeline powered by GitHub Actions for hassle-free deployments.

## Getting started

Pull the latest nightly build for your version of Odoo (e.g., 18.0):

```bash
docker pull ghcr.io/adomi-io/odoo:18.0
```

#### Supported versions


| Odoo                                               | Pull Command                                 |
|-|-|
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

Create a file in your project called `docker-compose.yml`

```yaml
version: '3.8'

services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    ports:
      - "8069:8069"
    environment:
      # Configure your instances
      ODOO_DB_HOST: ${DB_HOST:-db}
      ODOO_DB_PORT: ${DB_PORT:-5432}
      ODOO_DB_USER: ${DB_USER:-odoo}
      ODOO_DB_PASSWORD: ${DB_PASSWORD:-odoo}
    volumes:
      # Mount your addons
      - ./addons:/volumes/addons
      
      # Persist Odoo Data
      - odoo_data:/volumes/data
      
      # Mount a custom config
      # - ./src/odoo.conf:/volumes/config/odoo.conf
      
      # Add enterprise
      # - ./enterprise:/volumes/enterprise
    depends_on:
      - db
  db:
    image: postgres:13
    container_name: odoo_db
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-odoo}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-test}
      POSTGRES_DB: ${POSTGRES_DATABASE:-postgres}
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
volumes:
  odoo_data:
  pg_data:
```

Start your containers by running
```shell
docker compose up
```

If you want to always have Odoo running, you can add the following to your docker-compose.yml:

```yml
version: '3.8'

services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    restart: always # or you can use unless-stopped 
    # ...
```

then start the container in daemon mode by adding the `-d` flag

```shell
docker compose up -d
```
#### Logging into Your Container

Need to jump into your container like you would via SSH? With Docker Compose, it's as simple as:

```shell
docker compose exec odoo /bin/bash
```

This command drops you right into the container's shell for quick debugging or tweaks.

### Using an `.env` File

Manage your configuration variables safely and neatly with an .env file. By placing your sensitive data in this file and adding it to your .gitignore, 
you keep secrets out of your command line and source code.

#### Docker

1. **Create a `.env` file:**  
   Define your environment variables in a file named `.env` (or any name you choose). For example:

   ```env
   ODOO_DB_HOST=odoo_db
   ODOO_DB_PORT=5432
   ODOO_DB_USER=odoo
   ODOO_DB_PASSWORD=odoo
   ```

2. **Run your container using the env file:**  
   Use the `--env-file` flag with `docker run`:

   ```bash
   docker run --name odoo \
     --env-file .env \
     -p 8069:8069 \
     ghcr.io/adomi-io/odoo:18.0
   ```

This command loads all the variables from your `.env` file into the container.

#### Docker Compose

1. **Create a `.env` file:**  
   Place your `.env` file in the same directory as your `docker-compose.yml` file. Docker Compose automatically loads it. Alternatively, you can specify a different file name using the `env_file` key.

2. **Reference the env file in your Docker Compose file:**  
   You can explicitly reference the env file using the `env_file` directive:

   ```yaml
   version: '3.8'
   services:
     odoo:
       image: ghcr.io/adomi-io/odoo:18.0
       ports:
         - "8069:8069"
       env_file: .env
   ```

When you run `docker compose up`, Docker Compose will load the environment variables from the specified file, keeping your configuration tidy and secure.

Using an `.env` file makes it easy to manage environment-specific settings and ensures your sensitive data isn’t hard-coded into your commands or configuration files. 

### Using Secret Files

Keep your sensitive data secure by mounting secret files into `/run/secrets/`. Simply create a file named after the environment variable you want to set. For example, to set `ODOO_DB_PASSWORD`, create a file named `ODOO_DB_PASSWORD` containing your password (the file name is case-insensitive inside the container).

This approach lets you load any configuration option from a file.

#### Docker
Mount your secret file with the `-v` flag:

```bash
docker run --name odoo \
  -p 8069:8069 \
  -e ODOO_DB_HOST=odoo_db \
  -v $(pwd)/ODOO_DB_PASSWORD:/run/secrets/ODOO_DB_PASSWORD \
  -e ODOO_DB_PASSWORD=odoo \
  ghcr.io/adomi-io/odoo:18.0
```

#### Docker Compose
Docker Compose supports secret files natively. Create a file (e.g., `odoo_db_password.txt`) and reference it in your `docker-compose.yml`:

```yaml
version: '3.8'

services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    ports:
      - "8069:8069"
    environment:
      ODOO_DB_HOST: ${DB_HOST:-db}
      ODOO_DB_PORT: ${DB_PORT:-5432}
      ODOO_DB_USER: ${DB_USER:-odoo}
      # ODOO_DB_PASSWORD will be loaded from the secret file
      # ODOO_DB_PASSWORD: ${DB_PASSWORD:-odoo}
    secrets:
      - odoo_db_password

secrets:
  odoo_db_password:
    file: odoo_db_password.txt
```

This method keeps your secrets out of your code and environment, making your deployments more secure and flexible.
# Extending This Image

This image is built on Ubuntu, making it easy to extend. Customize your own image by setting default environment variables, baking your Odoo config, and adding your custom addons. You can even pre-build a container with Odoo Enterprise.


### Create a Custom Dockerfile

In your project's root, create a file named `Dockerfile`:

```dockerfile
FROM ghcr.io/adomi-io/odoo:18.0

# Optionally copy your custom config file
# COPY odoo.conf /volumes/config/odoo.conf

# Copy your custom addons into the container
COPY . /volumes/addons
```

### Running Your Image with Docker Compose

Instead of using the `image` tag in your `docker-compose.yml`, switch to a `build` context. For example, replace:

```yaml
version: '3.8'
services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    # ...
```

with:

```yaml
version: '3.1'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    # ...
```

Then build and start your container with:

```sh
docker compose build && docker compose up
```

### Note: Python Virtualenv

A virtual environment is already set up at `/venv` inside the container, with Odoo and its dependencies installed. 
This means you can run Python commands as usual:

```dockerfile
RUN pip install stripe
RUN pip install -r requirements.txt
RUN python myapp.py
```

This lets you easily extend and customize the container to fit your development needs. 
# Extending This Image with Odoo Enterprise

### Odoo Partners

If you're an Odoo Partner (or have GitHub access), extending your image is a breeze. First, clone the Enterprise repository into your project's root:

```bash
git clone git@github.com:odoo/enterprise.git
```

Then, create a `Dockerfile` in your project with the following content:

```dockerfile
FROM ghcr.io/adomi-io/odoo:18.0

# Copy the Enterprise addons into the folder located at /volumes/enterprise
COPY ./enterprise /volumes/enterprise
```

Finally, build and run your container:

```sh
docker compose build && docker compose up
```

### Downloaded Enterprise 

If you're not an Odoo Partner but have a valid Enterprise license, you can download Enterprise from [Odoo Downloads](https://www.odoo.com/page/download). Here's how:

1. **Download:** Grab the Enterprise file from the "Sources" row.
2. **Extract & Rename:** Extract the file, navigate to the `/odoo` directory, and rename the `addons` folder to `enterprise`.
3. **Copy:** Move the renamed `enterprise` folder to the top level of your project.

Create a `Dockerfile` with the following content:

```dockerfile
FROM ghcr.io/adomi-io/odoo:18.0

# Copy the Enterprise addons into the folder located at /volumes/enterprise
COPY ./enterprise /volumes/enterprise
```

Then, build and run your container:

```sh
docker compose build && docker compose up
```

*Note: Feel free to adjust the `COPY` command if your Enterprise code is stored elsewhere—placing it in the `enterprise` folder is just one option.*

# Configure Your Odoo Instances

This Docker container uses `envsubst` to generate an `odoo.conf` file based on your environment variables. This means you can configure Odoo at every stage of the image's lifecycle. Build values into your container, set them at runtime via a mounted file, or pass them through environment variables in your cloud provider's UI.

This documentation will guide you through configuring your Odoo instances.

## Default Odoo Configuration File

This image includes a default Odoo configuration that you can override, modify, or hardcode as needed.

The configuration file is located [here](./src/odoo.conf) and is stored in the container at `/volumes/config/odoo.conf`.

Some options, when set, change Odoo’s default behavior. To keep things flexible, many supported options are included in the entrypoint and Dockerfile but are commented out by default.

To see a complete list of options, review the default configuration file and simply uncomment the features you want to enable. You can mount the `odoo.conf` file at runtime or bake it into the image by extending it (see [Extending this image](#extending-this-image)).

The following options are enabled by default and can be set via environment variables:

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

# HTTP Service Configuration

# Activate reverse proxy WSGI wrappers (headers rewriting). Only enable this when running behind a trusted web proxy! (default: False)
proxy_mode = $ODOO_PROXY_MODE

# Multiprocessing options (POSIX only)

# Specify the number of workers, 0 disables prefork mode. (default: 0)
workers = $ODOO_WORKERS

# Maximum allowed virtual memory per worker (in bytes); when reached, the worker resets after the current request (default: 2147483648)
limit_memory_soft = $ODOO_LIMIT_MEMORY_SOFT

# Maximum allowed virtual memory per worker (in bytes); when reached, memory allocation fails (default: 2684354560)
limit_memory_hard = $ODOO_LIMIT_MEMORY_HARD

# Maximum allowed CPU time per request (default: 60)
limit_time_cpu = $ODOO_LIMIT_TIME_CPU

# Maximum allowed real time per request (default: 120)
limit_time_real = $ODOO_LIMIT_TIME_REAL
```

## Configure Default Options

You can configure the options from the [Default Odoo Configuration File](#default-odoo-configuration-file) using environment variables.

### Docker

Simply set the configuration options using the `-e` flag, prefixing the option name with `ODOO_`. For example, to set the number of workers:

```shell
docker run --name odoo \
  -p 8069:8069 \
  -e ODOO_DB_HOST=odoo_db \
  -e ODOO_DB_PORT=5432 \
  -e ODOO_DB_USER=odoo \
  -e ODOO_DB_PASSWORD=odoo \
  -e ODOO_WORKERS=5 \
  ghcr.io/adomi-io/odoo:18.0
```

### Docker Compose

You can also set these options in your `docker-compose.yml` file:

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
      # For example, setting the number of workers:
      ODOO_WORKERS: 5
```
## Use Your Own odoo.conf

#### Step 1: Create an `odoo.conf` File

Create a file in your project's folder called `odoo.conf`. We recommend copying the [default odoo.conf file provided with this image](./src/odoo.conf) and then modifying it with the values you want to use.

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

#### Step 2: Mount the Configuration File

##### Docker

Add the `-v $(pwd)/odoo.conf:/volumes/config/odoo.conf` flag to your `docker run` command. For example:

```shell
docker run -d \
  --name odoo \
  -p 8069:8069 \
  -v $(pwd)/odoo.conf:/volumes/config/odoo.conf \
  ghcr.io/adomi-io/odoo:18.0
```

##### Docker Compose

To use your custom configuration file with Docker Compose, update your `docker-compose.yml` to mount it at `/volumes/config/odoo.conf`:

```yaml
version: '3.8'
services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    # ...
    volumes:
      - ./odoo.conf:/volumes/config/odoo.conf # Add this to your docker compose configuration
```

## Environment Variable Defaults

The Dockerfile is built with a set of default environment variables. If you do not override these variables when deploying 
your Odoo container, the defaults will be used. For more details, check the [Dockerfile](./src/Dockerfile).


```dockerfile
ENV ODOO_CONFIG="/volumes/config/_generated.conf" \
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
    ODOO_LIMIT_REQUEST="65536" \
    IMAGE_SECRETS_DIR="/run/secrets" \
    IMAGE_ODOO_ENTERPRISE_LOCATION="/volumes/enterprise"
```

## Building Default Configuration into the Image

You can set the default values for the environment variables at build-time.

Copy the [odoo.conf](./src/odoo.conf) file, then uncomment or set the configuration options you’d like to support.

Setting the default with `ENV` will set that value if no environment variable is passed into the container. This lets you define defaults and override them later via environment variables or your cloud provider's UI at runtime.

```dockerfile
FROM ghcr.io/adomi-io/odoo:18.0

# Copy your config into the image
COPY odoo.conf /volumes/config/odoo.conf

# Set the default value for subsequent images.
# Specifying ODOO_WORKERS in the environment will now override this value;
# if ODOO_WORKERS is not set, it will default to 5.
ENV ODOO_WORKERS=5
```

## Setup Hook

When the container starts, it processes all the environment variables and their defaults to generate a `_generated.conf` file. 

Once that's done—but before Odoo launches—the entrypoint invokes a script located at `/hook_setup.sh`.

Use this hook to run any custom bash commands right before Odoo starts up. Simply mount your script to `/hook_setup.sh`.

*Note:* This script runs even if you’re using the container as a command-line utility (e.g., `scaffold`) and executes before the `wait-for-psql` script, so it doesn't guarantee that the database is reachable.

# Development with this container

You can use this container as a development environment, and debug your code. This assumes you have the [PyCharm
Odoo](https://plugins.jetbrains.com/plugin/13499-odoo) plugin by Trịnh Anh Ngọc. 

If you dont already have it, consider it, its excellent!


<details><summary>Use this container as a development environment w/ Breakpoints</summary>
## Docker Compose

Follow the [Docker Compose](#docker-compose) setup. This will mount your `./addons` folder into the container so that your changes are reflected immediately in Odoo.

> **Note:** For certain changes (e.g., UI updates), you'll need to go to `Apps` and update your app.

You can also use the virtual environment (`venv`) inside the container for debugging and setting breakpoints in PyCharm.

#### Considerations

Debugging in PyCharm uses `odoo-bin` directly, bypassing our entrypoint script. It's best to run the database in a separate `docker-compose.yml` file.

Create a `docker-compose-db.yml` file that contains just the database:

```yaml
version: '3.8'

services:
  db:
    image: postgres:13
    container_name: odoo_db
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-odoo}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-test}
      POSTGRES_DB: ${POSTGRES_DATABASE:-postgres}
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
volumes:
  pg_data:
```

Start the database with:

```shell
docker compose -f docker-compose-db.yml up
```

Then, create another file to run Odoo, named `docker-compose.yml`:

```yaml
version: '3.8'

services:
  odoo:
    build:
      context: ./src
      dockerfile: Dockerfile
    ports:
      - "8069:8069"
    environment:
      ODOO_DB_HOST: ${DB_HOST:-db}
      ODOO_DB_PORT: ${DB_PORT:-5432}
      ODOO_DB_USER: ${DB_USER:-odoo}
      ODOO_DB_PASSWORD: ${DB_PASSWORD:-odoo}
    volumes:
      - ./src/odoo.conf:/volumes/config/odoo.conf
      - ./addons:/volumes/addons
      - odoo_data:/volumes/data
      # Uncomment this to add enterprise at run-time:
      # - ./enterprise:/volumes/enterprise

    # This lets the container talk to software running on the host machine
    extra_hosts:
      - "host.docker.internal:host-gateway"

volumes:
  odoo_data:
```

#### Adding the venv as an Interpreter in PyCharm

1. Go to **File → Settings → Project → Python Interpreter**.
2. Click **Add Interpreter** and select **On Docker Compose**.

   ![dev_python_interpreter.png](./static/dev_python_interpreter.png)

3. Choose `odoo` as the service.

   ![dev_select_odoo.png](./static/dev_select_odoo.png)

4. Select the Python interpreter located in the `/venv` folder.

   ![dev_select_venv.png](./static/dev_select_venv.png)

5. Click **Create**.


#### Adding a Debug Configuration

1. Click the targets and edit the current configurations.

   ![dev_edit_configurations.png](./static/dev_edit_configurations.png)

2. Click **Add** in the top left and select an **Odoo** run configuration.

   ![dev_debug_config.png](./static/dev_debug_config.png)

3. Set the interpreter to the one you just set up. The `odoo-bin` file is located at `/odoo/odoo-bin`.

   > **Note:** This bypasses the `entrypoint.sh` script, so you need to set `db_host`, `db_user`, `db_password`, etc. manually in the `odoo-bin` arguments, or mount a hard-coded configuration file to `/volumes/config/_generated.conf` if you want to change settings while debugging.

4. Add the path mapping from `./addons` to `/volumes/addons`.

5. Click **OK**, then click the **Debug** button. You can now set breakpoints and debug your code.
</details>

## Debugging the Generated Config

The `odoo.conf` file is processed through `envsubst` and output to `/volumes/config/_generated.conf`. If you need to inspect the final configuration, simply mount the `/volumes/config` folder to your host.

For example, move your config file to `./config/odoo.conf` in your project, then update your Docker Compose configuration to mount the `./config` folder:

```yaml
version: '3.8'
services:
  odoo:
    image: ghcr.io/adomi-io/odoo:18.0
    # ...
    volumes:
      - ./config:/volumes/config # This mounts your config folder into the container
```

When the container starts, a `_generated.conf` file will appear in the `./config` folder, 
showing the final configuration used by Odoo.
# Maintaining This Repository

## Adding a New Version of Odoo

When Odoo launches a new version, they publish the changes on its own branch. This repository mirrors the Odoo version branch names.

When a new version is released, create a branch in this repository with the same name as the Odoo branch you wish to track.

Then, add the branch name to the [docker-publish.yml](./.github/workflows/docker-publish.yml) file under the `push` and `pull_request` sections.

The resulting image will be automatically built, unit-tested, deployed, and scheduled for nightly builds.



## Testing

### Unit Tests

The testing script is located in [./tests/unit-tests.sh](./tests/unit-tests.sh).

This script will create a Postgres database, install all selected Odoo addons, and run the corresponding unit tests.

To run these tests, clone the repository:

```sh
git clone git@github.com:adomi-io/odoo.git
```

Then, navigate to the tests folder:

```sh
cd odoo/tests
```

Finally, run the unit test script:

```sh
./tests/unit-tests.sh
```

### Front End Testing & Tours

Front end testing and tours are not currently finished.



# License

For license details, see the [LICENSE](https://github.com/adomi-io/odoo/blob/master/LICENSE) file in the repository.

