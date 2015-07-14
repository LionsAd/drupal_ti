#!/bin/bash
# @file
# Drupal-8 environment variables and functions.

function drupal_ti_install_drupal() {
	git clone --depth 1 --branch 8.0.x http://git.drupal.org/project/drupal.git
	cd drupal
	php -d sendmail_path=$(which true) ~/.composer/vendor/bin/drush.php --yes -v site-install minimal --db-url="$DRUPAL_TI_DB_URL"
}

function drupal_ti_clear_caches() {
	drush cr
}

export DRUPAL_TI_DRUSH_VERSION="drush/drush:dev-master"
export DRUPAL_TI_SIMPLETEST_FILE="core/scripts/run-tests.sh"
export DRUPAL_TI_MODULES_PATH="modules"
export DRUPAL_TI_DRUPAL_BASE="$TRAVIS_BUILD_DIR/../drupal-8"
export DRUPAL_TI_DRUPAL_DIR="$DRUPAL_TI_DRUPAL_BASE/drupal"
export DRUPAL_TI_DIST_DIR="$HOME/.dist"
export PATH="$DRUPAL_TI_DIST_DIR/usr/bin:$PATH"

# Display used for running selenium browser.
export DISPLAY=:99.0
