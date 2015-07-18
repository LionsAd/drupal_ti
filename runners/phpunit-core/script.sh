#!/bin/bash
# @file
# Simple script to run the core phpunit tests via travis-ci.

cd "$DRUPAL_TI_DRUPAL_DIR"

# Find absolute path to modules directory.
MODULE_DIR=$(cd "$DRUPAL_TI_MODULES_PATH"; pwd)

ARGS=( $DRUPAL_TI_PHPUNIT_ARGS )

# Run core tests
cd core
./vendor/bin/phpunit "${ARGS[@]}" "$MODULE_DIR/$DRUPAL_TI_MODULE_NAME/$DRUPAL_TI_PHPUNIT_CORE_SRC_DIRECTORY"
