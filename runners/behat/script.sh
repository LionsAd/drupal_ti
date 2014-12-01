#!/bin/bash
# @file
# Behat integration - Script step.

set -e $DRUPAL_TI_DEBUG

# Ensure we are in the right directory.
cd "$DRUPAL_TI_DRUPAL_DIR/$DRUPAL_TI_MODULES_PATH/$DRUPAL_TI_MODULE_NAME"

# Now go to the local behat tests, being within the module installation is
# needed for example for the drush runner.
# @todo Test this.
cd "$DRUPAL_TI_BEHAT_DIR"

# And run the tests.
ARGS=( $DRUPAL_TI_BEHAT_ARGS )
./vendor/bin/behat "${ARGS[@]}"
