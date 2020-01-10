#!/bin/bash
# @file
# Drupal-9 environment variables and functions.

function drupal_ti_install_drupal() {
	git clone --depth 1 --branch "$DRUPAL_TI_CORE_BRANCH" https://git.drupalcode.org/project/drupal.git
	cd drupal
	composer install

	# Installing Drush inside the project vendor directory is mandatory since Drupal 9.
	# @see https://github.com/drush-ops/drush/issues/4234.
	composer require --no-interaction "$DRUPAL_TI_DRUSH_VERSION"

	# Update PHPUnit to a specific version when required.
	if [ -n "$DRUPAL_TI_PHPUNIT_VERSION" ]
	then
		composer require phpunit/phpunit:"$DRUPAL_TI_PHPUNIT_VERSION" --no-interaction --update-with-dependencies
	fi

	# Add extra composer dependencies when required.
	if [ -n "$COMPOSER_EXTRA_DEPENDENCIES" ]
	then
		composer require $COMPOSER_EXTRA_DEPENDENCIES --no-interaction
	fi

	php -d sendmail_path=$(which true) ~/.composer/vendor/bin/drush --yes -v site-install "$DRUPAL_TI_INSTALL_PROFILE" --db-url="$DRUPAL_TI_DB_URL"
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
		echo "Module is already lined on: '$DRUPAL_TI_MODULES_PATH/$DRUPAL_TI_MODULE_NAME'"
		return
	fi

  # Explicitly set the repository as 0 and 1 override the default repository as
  # the local repository must be the first in the list.
	composer config repositories.0 path $TRAVIS_BUILD_DIR
	composer config repositories.1 composer https://packages.drupal.org/8
	composer require drupal/$DRUPAL_TI_MODULE_NAME *@dev
}

if [ -z "$DRUPAL_TI_DRUSH_VERSION" ]
then
  export DRUPAL_TI_DRUSH_VERSION="drush/drush:10.0.*"
fi
export DRUPAL_TI_SIMPLETEST_FILE="core/scripts/run-tests.sh"
export DRUPAL_TI_DRUPAL_BASE="$TRAVIS_BUILD_DIR/../drupal-9"
export DRUPAL_TI_DRUPAL_DIR="$DRUPAL_TI_DRUPAL_BASE/drupal"
export DRUPAL_TI_DIST_DIR="$HOME/.dist"
export PATH="$DRUPAL_TI_DIST_DIR/usr/bin:$PATH"
if [ -z "$DRUPAL_TI_CORE_BRANCH" ]
then
	export DRUPAL_TI_CORE_BRANCH="9.0.x"
fi

# The default folder for modules
export DRUPAL_TI_MODULES_PATH="modules/contrib"

# Display used for running selenium browser.
export DISPLAY=:99.0

# export SIMPLETEST_DB for KernelTestBase, so it is available for all runners.
export SIMPLETEST_DB="$DRUPAL_TI_DB_URL"

# export SIMPLETEST_BASE_URL for BrowserTestBase, so it is available for all runners.
export SIMPLETEST_BASE_URL="$DRUPAL_TI_WEBSERVER_URL:$DRUPAL_TI_WEBSERVER_PORT"

# Use 'minimal' by default for Drupal 9.
if [ -z "$DRUPAL_TI_INSTALL_PROFILE" ]
then
	export DRUPAL_TI_INSTALL_PROFILE="minimal"
fi
