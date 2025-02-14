# Adomi-io - Odoo
adomi/odoo mirrors the latest code from the official Odoo GitHub repository and is built nightly, 
ensuring you always run the most up-to-date version for your specific Odoo release.

Designed with multi-tenancy and cloud deployments in mind, this Docker container is ideal 
for running on platforms such as AWS ECS, Kubernetes, and more, or for building custom software 
solutions on top of Odoo. 

Configuration is streamlined through environment variables, making it 
simple to customize your setup without modifying the base image.

Features
---

- 🚀 **Cloud Native:** Designed for high-scale deployments on AWS ECS, Kubernetes, Lightsail, and Digital Ocean. Deploy anywhere with ease.  
- 🏗️ **Multi-Tenant Ready:** Optimized for SaaS and shared environments, supporting multiple tenants effortlessly.  
- 🔧 **Flexible Configuration:** Customize your Odoo instance instantly with environment variables and secret files—no rebuilds needed. Scale effortlessly.  
- 🤝 **Community Driven:** Built and maintained by the community, ensuring continuous improvements and real-world usability.  

Getting Started
---

Pull the latest nightly build for your version of Odoo (e.g., 18.0):

# `docker pull ghcr.io/adomi-io/odoo:18.0`

Supported Versions
---
| Version                                                   | Pull Command                               |
|-----------------------------------------------------------|--------------------------------------------|
| [18.0](https://github.com/adomi-io/odoo/tree/18.0)        | docker pull ghcr.io/adomi-io/odoo:18.0    |
| [17.0](https://github.com/adomi-io/odoo/tree/17.0)        | docker pull ghcr.io/adomi-io/odoo:17.0    |
| [16.0](https://github.com/adomi-io/odoo/tree/16.0)        | docker pull ghcr.io/adomi-io/odoo:16.0    |

Docker Compose 
---

```yaml
version: '3.8'
services:
  odoo:
    build:
      context: ./src
      dockerfile: Dockerfile
    container_name: odoo
    ports:
      - "8069:8069"
      - "8071:8071"
      - "8072:8072"
    environment:
      # Mandatory Options
      DB_HOST: ${DB_HOST:-db}
      DB_PORT: ${DB_PORT:-5432}
      DB_USER: ${DB_USER:-odoo}
      DB_PASSWORD: ${DB_PASSWORD:-odoo}

      # Optional Options
      # DB_NAME: ${DB_NAME:-postgres}
      # DATA_DIR: ${DATA_DIR:-/volumes/data}
      # ODOO_DEFAULT_ADDONS: ${ODOO_ADDONS_LOCATION:-/odoo/addons}
      # EXTRA_ADDONS: ${EXTRA_ADDONS:-/volumes/addons}
      # ADDONS_PATH: ${ADDONS_PATH:-/odoo/addons,/volumes/addons}
      # ADMIN_PASSWD: ${ADMIN_PASSWD:-admin}
      # CSV_INTERNAL_SEP: ${CSV_INTERNAL_SEP:-,}
      # DB_MAXCONN: ${DB_MAXCONN:-64}
      # DB_TEMPLATE: ${DB_TEMPLATE:-template1}
      # DBFILTER: ${DBFILTER:-.*}
      # DEBUG_MODE: ${DEBUG_MODE:-False}
      # EMAIL_FROM: ${EMAIL_FROM:-False}
      # LIMIT_MEMORY_HARD: ${LIMIT_MEMORY_HARD:-2684354560}
      # LIMIT_MEMORY_SOFT: ${LIMIT_MEMORY_SOFT:-2147483648}
      # LIMIT_REQUEST: ${LIMIT_REQUEST:-8192}
      # LIMIT_TIME_CPU: ${LIMIT_TIME_CPU:-60}
      # LIMIT_TIME_REAL: ${LIMIT_TIME_REAL:-120}
      # LIST_DB: ${LIST_DB:-True}
      # LOG_DB: ${LOG_DB:-False}
      # LOG_HANDLER: ${LOG_HANDLER:-[:INFO]}
      # LOG_LEVEL: ${LOG_LEVEL:-info}
      # LOGFILE: ${LOGFILE:-None}
      # LONGPOLLING_PORT: ${LONGPOLLING_PORT:-8072}
      # MAX_CRON_THREADS: ${MAX_CRON_THREADS:-2}
      # TRANSIENT_AGE_LIMIT: ${TRANSIENT_AGE_LIMIT:-1.0}
      # OSV_MEMORY_COUNT_LIMIT: ${OSV_MEMORY_COUNT_LIMIT:-False}
      # SMTP_PASSWORD: ${SMTP_PASSWORD:-False}
      # SMTP_PORT: ${SMTP_PORT:-25}
      # SMTP_SERVER: ${SMTP_SERVER:-localhost}
      # SMTP_SSL: ${SMTP_SSL:-False}
      # SMTP_USER: ${SMTP_USER:-False}
      # WORKERS: ${WORKERS:-0}
      # XMLRPC: ${XMLRPC:-True}
      # XMLRPC_INTERFACE: ${XMLRPC_INTERFACE:-}
      # XMLRPC_PORT: ${XMLRPC_PORT:-8069}
      # XMLRPCS: ${XMLRPCS:-True}
      # XMLRPCS_INTERFACE: ${XMLRPCS_INTERFACE:-}
      # XMLRPCS_PORT: ${XMLRPCS_PORT:-8071}
      # PSQL_WAIT_TIMEOUT: ${PSQL_WAIT_TIMEOUT:-30}
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

Odoo Configuration File
---
This image includes a default Odoo configuration, which you can override, modify, or hardcode as needed.  

The configuration file is located at `/etc/odoo/odoo.conf`.

Some configuration options, when set, alter Odoo’s default behavior. To maintain flexibility, many supported options are included but commented out by default.  

For details on extending this image, see the [Base Container](#) section.

```.conf
[options]
addons_path = $ADDONS_PATH
data_dir = $DATA_DIR
db_host = $DB_HOST
db_port = $DB_PORT
db_user = $DB_USER
db_password = $DB_PASSWORD

;db_name = $DB_NAME
;admin_passwd = $ADMIN_PASSWD
;csv_internal_sep = $CSV_INTERNAL_SEP
;db_maxconn = $DB_MAXCONN
;db_template = $DB_TEMPLATE
;dbfilter = $DBFILTER
;debug_mode = $DEBUG_MODE
;email_from = $EMAIL_FROM
;limit_memory_hard = $LIMIT_MEMORY_HARD
;limit_memory_soft = $LIMIT_MEMORY_SOFT
;limit_request = $LIMIT_REQUEST
;limit_time_cpu = $LIMIT_TIME_CPU
;limit_time_real = $LIMIT_TIME_REAL
;list_db = $LIST_DB
;log_db = $LOG_DB
;log_handler = $LOG_HANDLER
;log_level = $LOG_LEVEL
;logfile = $LOGFILE
;longpolling_port = $LONGPOLLING_PORT
;max_cron_threads = $MAX_CRON_THREADS
;transient_age_limit = $TRANSIENT_AGE_LIMIT
;osv_memory_count_limit = $OSV_MEMORY_COUNT_LIMIT
;smtp_password = $SMTP_PASSWORD
;smtp_port = $SMTP_PORT
;smtp_server = $SMTP_SERVER
;smtp_ssl = $SMTP_SSL
;smtp_user = $SMTP_USER
;workers = $WORKERS
;xmlrpc = $XMLRPC
;xmlrpc_interface = $XMLRPC_INTERFACE
;xmlrpc_port = $XMLRPC_PORT
;xmlrpcs = $XMLRPCS
;xmlrpcs_interface = $XMLRPCS_INTERFACE
;xmlrpcs_port = $XMLRPCS_PORT
```



Default Variables
--- 

### Mandatory Options

These variables are required for the container to connect to your database and store data:

| Variable    | Default Value      | Description                                       |
| ----------- | ------------------ | ------------------------------------------------- |
| DB_HOST     | `db`               | Hostname of the PostgreSQL server.                |
| DB_PORT     | `5432`             | Port number for the PostgreSQL server.            |
| DB_USER     | `odoo`             | Username for the PostgreSQL connection.           |
| DB_PASSWORD | `odoo`             | Password for the PostgreSQL connection.           |

### Optional Options

These variables let you fine-tune your Odoo configuration. Due to how Odoo works, you  may need to uncomment these items in your 
`odoo.conf` file.

| Variable               | Default Value                        | Description                                                            |
| ---------------------- | ------------------------------------ | ---------------------------------------------------------------------- |
| DB_NAME                | `postgres`                           | Name of the database to connect to.                                    |
| DATA_DIR    | `/volumes/data`    | Directory where Odoo stores its data/filestore.   |
| ODOO_DEFAULT_ADDONS    | `/odoo/addons`                       | Location of the default Odoo addons.                                   |
| EXTRA_ADDONS           | `/volumes/addons`                    | Directory for extra addons.                                            |
| ADDONS_PATH            | `/odoo/addons,/volumes/addons`         | Comma-separated list of directories where Odoo looks for addons.       |
| ADMIN_PASSWD           | `admin`                              | Administrator password for Odoo.                                       |
| CSV_INTERNAL_SEP       | `,`                                  | Separator used for CSV files.                                          |
| DB_MAXCONN             | `64`                                 | Maximum number of connections allowed to the PostgreSQL server.        |
| DB_TEMPLATE            | `template1`                          | Template database used for creating new databases.                     |
| DBFILTER               | `.*`                                 | Regex filter to limit the databases Odoo can see.                      |
| DEBUG_MODE             | `False`                              | Enable debug mode (set to `True` to enable).                           |
| EMAIL_FROM             | `False`                              | Default email address for outgoing emails.                             |
| LIMIT_MEMORY_HARD      | `2684354560`                         | Hard memory limit for Odoo (in bytes).                                 |
| LIMIT_MEMORY_SOFT      | `2147483648`                         | Soft memory limit for Odoo (in bytes).                                 |
| LIMIT_REQUEST          | `8192`                               | Maximum size for incoming requests.                                    |
| LIMIT_TIME_CPU         | `60`                                 | Maximum CPU time per request (in seconds).                             |
| LIMIT_TIME_REAL        | `120`                                | Maximum real time per request (in seconds).                            |
| LIST_DB                | `True`                               | Whether Odoo should list available databases.                          |
| LOG_DB                 | `False`                              | Enable logging to the database.                                        |
| LOG_HANDLER            | `[:INFO]`                           | Logging handler configuration.                                         |
| LOG_LEVEL              | `info`                               | Logging verbosity level.                                               |
| LOGFILE                | `None`                               | File path for logging output.                                          |
| LONGPOLLING_PORT       | `8072`                               | Port used for long polling.                                            |
| MAX_CRON_THREADS       | `2`                                  | Maximum number of cron threads.                                        |
| TRANSIENT_AGE_LIMIT    | `1.0`                                | Age limit for transient records.                                       |
| OSV_MEMORY_COUNT_LIMIT | `False`                              | Limit on OSV memory count.                                             |
| SMTP_PASSWORD          | `False`                              | SMTP server password.                                                  |
| SMTP_PORT              | `25`                                 | SMTP server port.                                                      |
| SMTP_SERVER            | `localhost`                          | SMTP server hostname.                                                  |
| SMTP_SSL               | `False`                              | Use SSL for SMTP connections.                                          |
| SMTP_USER              | `False`                              | SMTP server username.                                                  |
| WORKERS                | `0`                                  | Number of worker processes.                                            |
| XMLRPC                 | `True`                               | Enable the XMLRPC interface.                                           |
| XMLRPC_INTERFACE       | (empty)                              | Interface for XMLRPC (if not set, listens on all interfaces).          |
| XMLRPC_PORT            | `8069`                               | Port for the XMLRPC interface.                                         |
| XMLRPCS                | `True`                               | Enable the secure XMLRPC interface.                                    |
| XMLRPCS_INTERFACE      | (empty)                              | Interface for secure XMLRPC.                                           |
| XMLRPCS_PORT           | `8071`                               | Port for the secure XMLRPC interface.                                  |
| PSQL_WAIT_TIMEOUT      | `30`                                 | Timeout (in seconds) for waiting on PostgreSQL to be ready.            |

---

## Adding New Environment Variables

To add a new configuration variable:

1. **Set the Variable:** Add it to your environment (e.g., in your Docker Compose file, ECS task definition, or Kubernetes manifest).
2. **Update the Configuration:** Insert a placeholder for it in `odoo.conf`. For instance, if you add `MY_CUSTOM_VAR`, include:
   ```ini
   my_custom_setting = $MY_CUSTOM_VAR
   ```
3. **Deploy:** On container startup, the placeholder is replaced with the value from your environment.

License
---

For license details, see the [LICENSE](https://github.com/adomi-io/odoo/blob/master/LICENSE) file in the repository.

