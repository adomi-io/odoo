#! /bin/bash

export TESTS_DATABASE=${TESTS_DATABASE:-"testing"}
export TESTS_ADDONS=${TESTS_ADDONS:-"all"}

# Build the docker image and run the unit tests
#!/usr/bin/env bash

# 1. Build the base image
docker compose build
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -ne 0 ]; then
  echo "Build failed (exit code $BUILD_EXIT_CODE)"
  exit $BUILD_EXIT_CODE
fi

# 2. Run tests
docker compose \
  run \
  --rm odoo -- \
  --database "${TESTS_DATABASE}" \
  --init "${TESTS_ADDONS}" \
  --stop-after-init \
  --workers=0 \
  --max-cron-threads=0 \
  --test-tags='/base:TestRealCursor.test_connection_readonly'
#  --test-tags='standard,-/base:TestRealCursor.test_connection_readonly'

TEST_EXIT_CODE=$?
if [ $TEST_EXIT_CODE -ne 0 ]; then
  echo "Tests failed (exit code $TEST_EXIT_CODE)"
  exit $TEST_EXIT_CODE
fi

echo "All tests passed successfully. ${TEST_EXIT_CODE}"


