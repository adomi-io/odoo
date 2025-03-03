#!/usr/bin/env bash

# Configuration options for this script
export TESTS_DATABASE=${TESTS_DATABASE:-"testing"}
export TESTS_ADDONS=${TESTS_ADDONS:-"all"}
export TESTS_IMAGE_TAG=${TESTS_IMAGE_TAG:-"testing-image"}
export TESTS_DOCKERFILE=${TESTS_DOCKERFILE:-"Dockerfile"}
export TESTS_WORKDIR=${TESTS_WORKDIR:-"../src"}

export TESTS_POSTGRES_IMAGE=${TESTS_POSTGRES_SERVER_VERSION:-"postgres:17"}
export TESTS_ODOO_CONTAINER_NAME=${TESTS_ODOO_CONTAINER_NAME:-"odoo_testing_container"}
export TESTS_POSTGRES_CONTAINER_NAME=${TESTS_POSTGRES_CONTAINER_NAME:-"${TESTS_ODOO_CONTAINER_NAME}_db"}

export TESTS_DB_HOST=${TESTS_DB_HOST:-"${TESTS_POSTGRES_CONTAINER_NAME}"}
export TESTS_DB_USER=${TESTS_DB_USER:-"odoo"}
export TESTS_DB_PASSWORD=${TESTS_DB_PASSWORD:-"odoo"}
export TESTS_DB_NAME=${TESTS_DB_NAME:-"testing"}
export TESTS_TEST_TAGS=${TESTS_TEST_TAGS:-"-/base:TestRealCursor.test_connection_readonly"}
export TESTS_SKIP_BUILD=${TESTS_SKIP_BUILD:-"true"}
export ODOO_VERSION=${ODOO_VERSION:-"18.0"}

# Ensure we do not have a lingering odoo_testing_db
docker rm -f "${TESTS_POSTGRES_CONTAINER_NAME}" 2>/dev/null || true

# Optionally skip building the image
if [ "${SKIP_BUILD}" != "true" ]; then
  # Build the testing image
  docker build -t "${TESTS_IMAGE_TAG}" \
    --build-arg ODOO_VERSION=${ODOO_VERSION} \
    -f "${TESTS_WORKDIR}/${TESTS_DOCKERFILE}" \
    "${TESTS_WORKDIR}"

  BUILD_EXIT_CODE=$?

  if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "Build failed (exit code $BUILD_EXIT_CODE)"
    exit $BUILD_EXIT_CODE
  fi
else
  echo "Skipping image build as SKIP_BUILD is set to true."
fi


# Start the database as a daemon
docker run -d \
  --name "${TESTS_POSTGRES_CONTAINER_NAME}" \
  -e POSTGRES_USER="${TESTS_DB_USER}" \
  -e POSTGRES_PASSWORD="${TESTS_DB_PASSWORD}" \
  -e POSTGRES_DB="${TESTS_DB_NAME}" \
  -e POSTGRES_INITDB_ARGS="--locale=en_US.utf8 --lc-collate=en_US.utf8 --lc-ctype=en_US.utf8" \
  "${TESTS_POSTGRES_IMAGE}"

# Wait for the postgres database to start
while ! docker inspect -f '{{.State.Running}}' "${TESTS_POSTGRES_CONTAINER_NAME}" | grep true > /dev/null; do
  echo "Waiting for ${TESTS_POSTGRES_CONTAINER_NAME} to be running..."
  sleep 1
done

# Get the first argument to the script or use default config
CONFIG_FILE="${1:-$(pwd)/../src/odoo.conf}"

echo "${CONFIG_FILE}"

# Test the docker container

# By default, we should ignore the /volumes/addons folder since at build time
# we wont have anything there, and the upgrade command will fail because
# this is not a valid addon directory as an empty folder
docker run \
  --name "${TESTS_ODOO_CONTAINER_NAME}" \
  --link "${TESTS_POSTGRES_CONTAINER_NAME}:${TESTS_POSTGRES_CONTAINER_NAME}" \
  -v "${CONFIG_FILE}":/volumes/config/odoo.conf \
  -e ODOO_DB_HOST="${TESTS_DB_HOST}" \
  -e ODOO_DB_PORT="${TESTS_DB_PORT:-5432}" \
  -e ODOO_DB_USER="${DB_USER:-odoo}" \
  -e ODOO_DB_PASSWORD="${DB_PASSWORD:-odoo}" \
  -e ODOO_ADDONS_PATH="${TESTS_ADDONS_PATH:-/odoo/addons}" \
  --rm "${TESTS_IMAGE_TAG}" \
  --database "${TESTS_DATABASE}" \
  --init "${TESTS_ADDONS}" \
  --stop-after-init \
  --workers=0 \
  --max-cron-threads=0 \
  --test-tags="${TESTS_TEST_TAGS}"

# Capture the exit code of the last command
TEST_EXIT_CODE=$?

# Cleanup our mess
docker stop odoo_testing_db

# Print our result and return the test status if
# the status code does not equal 0
if [ $TEST_EXIT_CODE -ne 0 ]; then
  echo "Tests failed (exit code $TEST_EXIT_CODE)"
  exit $TEST_EXIT_CODE
fi

# Everything passed!
echo "All tests passed successfully. ${TEST_EXIT_CODE}"


