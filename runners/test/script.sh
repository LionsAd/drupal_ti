#!/bin/bash

test -f "test-include-success.txt" || exit 1
cd $DRUPAL_TI_TESTS_DIR
./tests/run-tests.sh
