#!/usr/bin/env bash
set -euo pipefail

# Generic, declarative module init/update driven entirely by env.
#
#   ODOO_INIT   = comma-separated modules to install  (odoo-bin -i)
#   ODOO_UPDATE = comma-separated modules to update    (odoo-bin -u)
#
# Both unset/empty => no-op (the common case for a plain run). This is what
# makes `ODOO_INIT` actually do something: the generated odoo.conf leaves
# `init`/`update` commented, so without this hook those env vars are inert.
#
# Safe to run on every boot:
#   -i only installs modules that are NOT yet installed (already-installed are
#      skipped), so first boot creates the schema and later boots are a no-op.
#   -u re-applies a module's migrations, the conventional "run migrations on
#      deploy" pattern.

ODOO_INIT="${ODOO_INIT:-}"
ODOO_UPDATE="${ODOO_UPDATE:-}"

if [[ -z "${ODOO_INIT}" && -z "${ODOO_UPDATE}" ]]; then
  exit 0
fi

ODOO_DB_NAME="${ODOO_DB_NAME:-odoo}"
# The entrypoint generated and exported the real config before invoking hooks.
ODOO_RC="${ODOO_RC:-/etc/odoo/odoo.conf}"

echo "[hook:odoo_init] waiting for Postgres at ${ODOO_DB_HOST:-?}:${ODOO_DB_PORT:-5432} ..."
# Setup hooks run before the entrypoint's own wait-for-psql, so wait here.
/usr/local/bin/wait-for-psql.py

args=( -c "${ODOO_RC}" -d "${ODOO_DB_NAME}" --stop-after-init )
[[ -n "${ODOO_INIT}" ]]   && args+=( -i "${ODOO_INIT}" )
[[ -n "${ODOO_UPDATE}" ]] && args+=( -u "${ODOO_UPDATE}" )

echo "[hook:odoo_init] odoo-bin ${args[*]}"
odoo-bin "${args[@]}"
echo "[hook:odoo_init] done."
