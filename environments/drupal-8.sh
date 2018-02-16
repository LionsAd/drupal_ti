#!/bin/bash
# @file
# Drupal-8 environment variables and functions.

function drupal_ti_install_drupal() {
	git clone --depth 1 --branch "$DRUPAL_TI_CORE_BRANCH" http://git.drupal.org/project/drupal.git
	cd drupal
	composer install

	# Add extra composer dependencies when required.
	if [ -z "$COMPOSER_EXTRA_DEPENDENCIES" ]
	then
		composer require "$COMPOSER_EXTRA_DEPENDENCIES" --no-interaction
	fi

	php -d sendmail_path=$(which true) ~/.composer/vendor/bin/drush.php --yes -v site-install "$DRUPAL_TI_INSTALL_PROFILE" --db-url="$DRUPAL_TI_DB_URL"
	drush use $(pwd)#default
}

function drupal_ti_clear_caches() {
	drush cr
}

#
# Ensures that the module is linked into the Drupal code base.
#
function drupal_ti_ensure_module_linked() {
	# Ensure we are in the right directory.
	cd "$DRUPAL_TI_DRUPAL_DIR"

	# This function is re-entrant.
	if [ -L "$DRUPAL_TI_MODULES_PATH/$DRUPAL_TI_MODULE_NAME" ]
	then
		return
	fi

  # Explicitly set the repository as 0 and 1 override the default repository as
  # the local repository must be the first in the list.
	composer config repositories.0 path $TRAVIS_BUILD_DIR
	composer config repositories.1 composer https://packages.drupal.org/8
	composer require drupal/$DRUPAL_TI_MODULE_NAME *@dev
}

export DRUPAL_TI_DRUSH_VERSION="drush/drush:8.0.*"
export DRUPAL_TI_SIMPLETEST_FILE="core/scripts/run-tests.sh"
export DRUPAL_TI_DRUPAL_BASE="$TRAVIS_BUILD_DIR/../drupal-8"
export DRUPAL_TI_DRUPAL_DIR="$DRUPAL_TI_DRUPAL_BASE/drupal"
export DRUPAL_TI_DIST_DIR="$HOME/.dist"
export PATH="$DRUPAL_TI_DIST_DIR/usr/bin:$PATH"
if [ -z "$DRUPAL_TI_CORE_BRANCH" ]
then
	export DRUPAL_TI_CORE_BRANCH="8.1.x"
fi

# The default folder for modules changes in 8.3.x.
if [ "${DRUPAL_TI_CORE_BRANCH:2:1}" -gt "2" ]
then
  export DRUPAL_TI_MODULES_PATH="modules/contrib"
else
  export DRUPAL_TI_MODULES_PATH="modules"
fi

# Display used for running selenium browser.
export DISPLAY=:99.0

# export SIMPLETEST_DB for KernelTestBase, so it is available for all runners.
export SIMPLETEST_DB="$DRUPAL_TI_DB_URL"

# export SIMPLETEST_BASE_URL for BrowserTestBase, so it is available for all runners.
export SIMPLETEST_BASE_URL="$DRUPAL_TI_WEBSERVER_URL:$DRUPAL_TI_WEBSERVER_PORT"

# Use 'minimal' by default for Drupal 8.
if [ -z "$DRUPAL_TI_INSTALL_PROFILE" ]
then
	export DRUPAL_TI_INSTALL_PROFILE="minimal"
fi
