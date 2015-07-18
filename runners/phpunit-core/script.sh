#!/bin/bash
# @file
# Simple script to run the core phpunit tests via travis-ci.

cd "$DRUPAL_TI_DRUPAL_DIR"

# Find absolute path to modules directory.
MODULE_DIR=$(cd "$DRUPAL_TI_MODULES_PATH"; pwd)

# Run core tests
cd core
./vendor/bin/phpunit --verbose --debug "$MODULE_DIR/$DRUPAL_TI_MODULE_NAME"
