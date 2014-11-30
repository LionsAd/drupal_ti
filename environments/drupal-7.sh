#!/bin/bash
# @file
# Drupal-7 environment variables and functions.

function drupal_ti_install_drupal() {
	php -d sendmail_path=$(which true) ~/.composer/vendor/bin/drush.php --yes core-quick-drupal --profile=testing --no-server --db-url="$DRUPAL_TI_DB_URL" .
}

function drupal_ti_clear_caches() {
	drush cc all
}

export DRUPAL_TI_DRUSH_VERSION="drush/drush:6.*"
export DRUPAL_TI_SIMPLETEST_FILE="scripts/run-tests.sh"
export DRUPAL_TI_MODULES_PATH="sites/all/modules"
export DRUPAL_TI_DRUPAL_BASE="$TRAVIS_BUILD_DIR/../drupal-7"
export DRUPAL_TI_DRUPAL_DIR="$DRUPAL_TI_DRUPAL_BASE/drupal"
