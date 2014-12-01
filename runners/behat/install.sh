#!/bin/bash
# @file
# Behat integration - Install step.

set -e $DRUPAL_TI_DEBUG

cd "$TRAVIS_BUILD_DIR/$DRUPAL_TI_BEHAT_DIR"

composer install --no-interaction --prefer-source --dev
