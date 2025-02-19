#! /bin/bash

export TESTS_DATABASE=${TESTS_DATABASE:-"testing"}
export TESTS_ADDONS=${TESTS_ADDONS:-"base,web"}

# Build the docker image and run the unit tests
#!/usr/bin/env bash

# 1. Build
docker compose build
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -ne 0 ]; then
  echo "Build failed (exit code $BUILD_EXIT_CODE)"
  exit $BUILD_EXIT_CODE
fi

# 2. Run tests
docker compose run --rm odoo -- \
  -d "${TESTS_DATABASE}" \
  --update="${TESTS_ADDONS}" \
  --stop-after-init \
  --test-enable

TEST_EXIT_CODE=$?
if [ $TEST_EXIT_CODE -ne 0 ]; then
  echo "Tests failed (exit code $TEST_EXIT_CODE)"
  exit $TEST_EXIT_CODE
fi

echo "All tests passed successfully. ${TEST_EXIT_CODE}"


