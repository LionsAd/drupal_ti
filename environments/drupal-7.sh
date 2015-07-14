#!/bin/bash
# @file
# Drupal-7 environment variables and functions.

function drupal_ti_install_drupal() {
	drush --yes dl drupal-7 --drupal-project-rename=drupal
	cd drupal
	php -d sendmail_path=$(which true) ~/.composer/vendor/bin/drush.php --yes site-install testing --db-url="$DRUPAL_TI_DB_URL"
}

function drupal_ti_clear_caches() {
	drush cc all
}

export DRUPAL_TI_DRUSH_VERSION="drush/drush:dev-master"
export DRUPAL_TI_SIMPLETEST_FILE="scripts/run-tests.sh"
export DRUPAL_TI_MODULES_PATH="sites/all/modules"
export DRUPAL_TI_DRUPAL_BASE="$TRAVIS_BUILD_DIR/../drupal-7"
export DRUPAL_TI_DRUPAL_DIR="$DRUPAL_TI_DRUPAL_BASE/drupal"
export DRUPAL_TI_DIST_DIR="$HOME/.dist"
export PATH="$DRUPAL_TI_DIST_DIR/usr/bin:$PATH"

# Display used for running selenium browser.
export DISPLAY=:99.0

# PHP 5.3 needs Drush 6
PHP_VERSION=$(phpenv version-name)
if [ "$PHP_VERSION" = "5.3" ]
then
	export DRUPAL_TI_DRUSH_VERSION="drush/drush:6.*"
fi
