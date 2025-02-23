#!/usr/bin/env bash

export TESTS_DATABASE=${TESTS_DATABASE:-"testing"}
export TESTS_ADDONS=${TESTS_ADDONS:-"all"}

# 1. Build the base image
docker build -t testing_image -f ../src/Dockerfile ../src

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -ne 0 ]; then
  echo "Build failed (exit code $BUILD_EXIT_CODE)"
  exit $BUILD_EXIT_CODE
fi

# Start the database
docker run -d \
  --name odoo_testing_official_container_db \
  -e POSTGRES_USER="${POSTGRES_USER:-odoo}" \
  -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-odoo}" \
  -e POSTGRES_DB="${POSTGRES_DATABASE:-postgres}" \
  postgres:13

while ! docker inspect -f '{{.State.Running}}' odoo_testing_official_container_db | grep true > /dev/null; do
  echo "Waiting for odoo_testing_official_container_db to be running..."
  sleep 1
done

# 2. Run tests
docker run \
  --name odoo_testing_official_container \
  --link odoo_testing_official_container_db:odoo_testing_official_container_db \
  -p 8069:8069 \
  -e HOST="${DB_HOST:-odoo_testing_official_container_db}" \
  -e PORT="${DB_PORT:-5432}" \
  -e USER="${DB_USER:-odoo}" \
  -e PASSWORD="${DB_PASSWORD:-odoo}" \
  --rm odoo:18.0 \
  --database "${TESTS_DATABASE}" \
  --init "${TESTS_ADDONS}" \
  --stop-after-init \
  --workers=0 \
  --max-cron-threads=0 \
  --test-tags='/base:TestRealCursor.test_connection_readonly'

TEST_EXIT_CODE=$?

# Cleanup our mess
docker stop odoo_testing_official_container_db && \
docker rm odoo_testing_official_container_db

if [ $TEST_EXIT_CODE -ne 0 ]; then
  echo "Tests failed (exit code $TEST_EXIT_CODE)"
  exit $TEST_EXIT_CODE
fi

echo "All tests passed successfully. ${TEST_EXIT_CODE}"


