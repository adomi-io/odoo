# Odoo Docker

This is a community supported version of Odoo's docker image. 

This project is a rewrite of the [odoo/docker](https://github.com/odoo/docker) image

This guide describes an approach for running Odoo with a focus on multi-tenancy and environment-driven configuration. 
The goal is to let you override `odoo.conf` settings using environment variables—without modifying the image.

---

## Key Features

1. **Environment Variable Substitution**  
   By leveraging [`envsubst`](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html), the container merges environment variables into an Odoo configuration template at startup. This allows you to:
   - Override all of Odoo’s config (database host, port, user, password, workers, etc.) via Docker, ECS, Lightsail or Kubernetes environment variables.
   - Set the number of workers and their available settings from the environment, without needing to rebuild the base image
   - Keep sensitive info (like DB credentials) out of logs by not passing them as command-line arguments.

2. **Multi-Tenancy Friendly**  
   - Specify database names 
   - The `dbfilter` setting can be set dynamically with environment variables, making it easier to serve multiple Odoo databases from a single container or a single host.  
   - Minimizes static references to specific databases in container commands, offering more flexible setups.

3. **Wait-for-Postgres Logic**  
   - A small script is included to wait for your PostgreSQL service to be ready before starting Odoo.  
   - This avoids race conditions where Odoo might launch before the database is accepting connections.

4. **Works in Any Environment**  
   - Docker Compose, AWS ECS, Kubernetes, Docker Swarm, or any environment that can inject environment variables will benefit from this approach.
   - Official or custom Docker registries are supported.

---

## How It Works

1. **Docker Build & Base Setup**  
   - The image is built on Ubuntu (or a similar Linux base).
   - Installs `odoo` from the chosen version (e.g., 18.0) along with necessary dependencies like `wkhtmltopdf`, `postgresql-client`, `rtlcss`, and `envsubst`.

2. **Configuration Template**  
   - A template `odoo.conf` is baked into the image. Its fields (e.g., `$DB_HOST`, `$DB_PORT`, `$WORKERS`) reference environment variables.
   - At runtime, these placeholders are replaced with actual values from the environment. If an environment variable is unset, a default is provided in the entrypoint.

3. **Entrypoint Script**  
   - Reads environment variables (with sensible defaults), including optional secrets from a file (e.g., `PASSWORD_FILE`) if needed.
   - Calls `envsubst` to merge those variables into the final `odoo.conf`.
   - Invokes the “wait-for-psql” script to confirm PostgreSQL is live.
   - Launches Odoo once the database is ready.

4. **Wait-for-PSQL**  
   - A Python-based check that uses `pg_isready` (from PostgreSQL) or direct connection attempts to confirm the database is accepting connections.
   - Times out after a specified duration (configurable via `PSQL_WAIT_TIMEOUT`).

---

## Usage

will update once deployed

---

## Example Docker Compose

will update this once deployed on Dockerhub

---

## Contributing


## Development

`docker compose build && docker compose up`