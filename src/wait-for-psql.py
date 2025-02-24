#!/usr/bin/env python3
import argparse
import configparser
import logging
import os
import subprocess
import time



class DatabaseConnectionError(Exception):
    pass

if __name__ == '__main__':
    # Load options from the env
    default_config_path = os.getenv('ODOO_RC', '/volumes/config/_generated.conf')
    default_psql_wait_timeout = os.getenv('PSQL_WAIT_TIMEOUT', 30)

    # Load options from the command line
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('--config', type=str, default=default_config_path)
    arg_parser.add_argument('--db-host', type=str)
    arg_parser.add_argument('--db-port', type=int)
    arg_parser.add_argument('--db-user', type=str)
    arg_parser.add_argument('--timeout', type=int, default=default_psql_wait_timeout)
    arg_parser.add_argument('--log-level', type=str, default='INFO')
    args, _ = arg_parser.parse_known_args()

    # Read the Odoo configuration
    # This can probably use the odoo config.py file and that would solve
    # the args and config options
    config = configparser.ConfigParser()
    config.read(args.config)
    config_db_host = config.get('options', 'db_host', fallback='localhost')
    config_db_port = config.get('options', 'db_port', fallback=5432)
    config_db_user = config.get('options', 'db_user', fallback=5432)
    config_log_level = config.get('options', 'log_level', fallback='INFO')

    # Use the args if they are specified, otherwise, use the values from the config
    db_host = args.db_host or config_db_host
    db_port = args.db_port or config_db_port
    db_user = args.db_user or config_db_user

    logging.basicConfig(
        format="%(asctime)s - %(levelname)s - %(message)s",
        level=logging.INFO
    )

    logging.info("Waiting for database(s) to be ready ...")
    logging.info(f"Host: {db_user}@{db_host}:{db_port}")
    logging.info(f"Timeout: {args.timeout} seconds")

    start_time = time.time()

    status, exit_code = "", 0

    while time.time() < start_time + args.timeout:
        result = subprocess.run(
            [
                "pg_isready",
                "-h", db_host,
                "-p", str(db_port),
                "-U", db_user,
                "-t", str(args.timeout)
            ],
            capture_output=True,
            text=True
        )

        status, exit_code = (
            result.stdout.strip(),
            result.returncode
        )

        logging.info(status)

        if exit_code == 0:
            break

        time.sleep(1)

    if exit_code != 0:
        raise DatabaseConnectionError(f"Unable to connect to the database. Exit code: {exit_code} - Message: {status}")

    logging.info("🚀 Database(s) are ready.")
