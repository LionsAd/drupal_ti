#!/bin/bash
# @file
# Common functionality for common tasks.

#
# Ensures that the right Drupal version is installed.
#
function drupal_ti_ensure_drupal() {
	# This function is re-entrant.
	if [ -d "$DRUPAL_TI_DRUPAL_DIR" ]
	then
		return
	fi

	# HHVM env is broken: https://github.com/travis-ci/travis-ci/issues/2523.
	PHP_VERSION=`phpenv version-name`
	if [ "$PHP_VERSION" = "hhvm" ]
	then
		# Create sendmail command, which links to /bin/true for HHVM.
		BIN_DIR="$TRAVIS_BUILD_DIR/../drupal_travis/bin"
		mkdir -p "$BIN_DIR"
		ln -s $(which true) "$BIN_DIR/sendmail"
		export PATH="$BIN_DIR:$PATH"
	fi

	# Create database and install Drupal.
	mysql -e "create database $DRUPAL_TI_DB"

	mkdir -p "$DRUPAL_TI_DRUPAL_BASE"
	cd "$DRUPAL_TI_DRUPAL_BASE"

	drupal_ti_install_drupal
}

#
# Ensures that the module is linked into the Drupal code base
# and enabled.
#
function drupal_ti_ensure_module() {
	# Ensure we are in the right directory.
	cd "$DRUPAL_TI_DRUPAL_DIR"

	# This function is re-entrant.
	if [ -L "$DRUPAL_TI_MODULES_PATH/$DRUPAL_TI_MODULE_NAME" ]
	then
		return
	fi

	# Find absolute path to module.
	MODULE_DIR=$(cd "$TRAVIS_BUILD_DIR"; pwd)

	# Ensure directory exists.

	mkdir -p "$DRUPAL_TI_MODULES_PATH"

	# Point module into the drupal installation.
	ln -sf "$MODULE_DIR" "$DRUPAL_TI_MODULES_PATH/$DRUPAL_TI_MODULE_NAME"

	# Enable it to download dependencies.
	drush --yes en "$DRUPAL_TI_MODULE_NAME"
}

#
# Run a webserver and wait until it is started up.
#
function drupal_ti_run_server() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-drush-server-running" ]
	then
		return
	fi

	# start a web server on port 8080, run in the background; wait for initialization
	{ drush runserver "$DRUPAL_TI_WEBSERVER_URL:$DRUPAL_TI_WEBSERVER_PORT" | drupal_ti_log_output "webserver" ; } &
	until netstat -an 2>/dev/null | grep -q "$DRUPAL_TI_WEBSERVER_PORT.*LISTEN"
	do
		sleep 1
	done
	touch "$TRAVIS_BUILD_DIR/../drupal_ti-drush-server-running"
}

#
# Ensures a drush webserver can be started for PHP 5.3.
#
function drupal_ti_ensure_php_for_drush_webserver() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-php-for-webserver-installed" ]
	then
		return
	fi

	# install php packages required for running a web server from drush on php 5.3
	PHP_VERSION=$(phpenv version-name)
	if [ "$PHP_VERSION" = "5.3" ]
	then
		sudo apt-get update > /dev/null
		sudo apt-get install -y --force-yes php5-cgi php5-mysql
	fi
	touch "$TRAVIS_BUILD_DIR/../drupal_ti-php-for-webserver-installed"
}
