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

	# Find absolute path to module.
	MODULE_DIR=$(cd "$TRAVIS_BUILD_DIR"; pwd)

	# Ensure directory exists.

	mkdir -p "$DRUPAL_TI_MODULES_PATH"

	# Point module into the drupal installation.
	ln -sf "$MODULE_DIR" "$DRUPAL_TI_MODULES_PATH/$DRUPAL_TI_MODULE_NAME"
}


#
# Ensures that the module is linked into the Drupal code base
# and enabled.
#
function drupal_ti_ensure_module() {
	# Ensure the module is linked into the code base.
	drupal_ti_ensure_module_linked

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

	# Use hhvm_serve for PHP 5.3 fcgi and hhvm fcgi
	PHP_VERSION=$(phpenv version-name)

	# Hack: Remove me.
	PHP_VERSION="hhvm"
	
	if [ "$PHP_VERSION" = "5.3" -o "$PHP_VERSION" = "hhvm" ]
	then
		export GOPATH="$DRUPAL_TI_DIST_DIR/go"
		export DRUPAL_TI_WEBSERVER_HOST=$(echo "$DRUPAL_TI_WEBSERVER_URL" | sed 's,http://,,')
		{ "$GOPATH/bin/hhvm-serve" -listen="$DRUPAL_TI_WEBSERVER_HOST:$DRUPAL_TI_WEBSERVER_PORT" 2>&1 | drupal_ti_log_output "webserver" ; } &
	else
		# start a web server on port 8080, run in the background; wait for initialization
		{ drush runserver "$DRUPAL_TI_WEBSERVER_URL:$DRUPAL_TI_WEBSERVER_PORT" 2>&1 | drupal_ti_log_output "webserver" ; } &
	fi

	# Wait until drush server has been started.
	drupal_ti_wait_for_service_port "$DRUPAL_TI_WEBSERVER_PORT"
	touch "$TRAVIS_BUILD_DIR/../drupal_ti-drush-server-running"
}

#
# Ensure hhvm runs in daemon mode.
#
function drupal_ti_ensure_hhvm_fastcgi() {
	# PHP-FPM
	export DRUPAL_TI_HHVM_INI="$TRAVIS_BUILD_DIR/../php-hhvm.ini"
cat <<EOF >"$DRUPAL_TI_HHVM_INI"
; php options

pid = /tmp/hhvm.pid

; hhvm specific

hhvm.server.port = 9000
hhvm.server.type = fastcgi
hhvm.server.default_document = index.php
hhvm.log.use_log_file = true
hhvm.log.file = /tmp/hhvm-error.log
hhvm.repo.central.path = /tmp/hhvm.hhbc
auto_prepend_file = $DRUPAL_TI_SCRIPT_DIR/utility/hhvm-serve-prepend-drupal-ti.php

; MySQL optimization
mysql.connect_timeout = 3000
default_socket_timeout = 3000
EOF

	hhvm --config "$DRUPAL_TI_HHVM_INI" --mode daemon
	sleep 2
	{ tail -f /tmp/hhvm-error.log | drupal_ti_log_output "hhvm"; } &
}

#
# Ensure that PHP FPM runs.
#
function drupal_ti_ensure_php_fpm() {
	# PHP-FPM
	export DRUPAL_TI_PHP_FPM_CONF="$TRAVIS_BUILD_DIR/../php-fpm.conf"
cat <<EOF >"$DRUPAL_TI_PHP_FPM_CONF"
error_log = /tmp/fpm-php.log

[www]
user = travis
group = travis

listen = 9000
listen.owner = travis
listen.group = travis
listen.mode = 0666
listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

pm.status_path = /php-fpm-status
ping.path = /php-fpm-ping
php_value[auto_prepend_file] = $DRUPAL_TI_SCRIPT_DIR/utility/hhvm-serve-prepend-drupal-ti.php
EOF
	{ php-fpm -F -y "$DRUPAL_TI_PHP_FPM_CONF" | drupal_ti_log_output "php-fpm"; } &
}

#
# Ensure that hhvm_serve is installed
#
function drupal_ti_ensure_hhvm_serve() {
	export GOPATH="$DRUPAL_TI_DIST_DIR/go"
	mkdir -p "$GOPATH"
	go get -v -u github.com/LionsAd/hhvm-serve
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
	if [ "$PHP_VERSION" != "5.3" -a "$PHP_VERSION" != "hhvm" ]
	then
		# Hack: Remove me.
		#return
		echo "Overriding PHP version check" 1>&2
	fi
	if [ "$PHP_VERSION" = "hhvm" ]
	then
		drupal_ti_ensure_hhvm_fastcgi
	else
		drupal_ti_ensure_php_fpm
	fi

	drupal_ti_ensure_hhvm_serve
	touch "$TRAVIS_BUILD_DIR/../drupal_ti-php-for-webserver-installed"
}

#
# Waits until a service using a port is ready.
#
function drupal_ti_wait_for_service_port() {
	PORT=$1
	shift

	COUNT=0
	# Try to connect to the port via netcat.
	# netstat is not available on the container builds.
	until nc -w 1 localhost "$PORT"
	do
		sleep 1
		COUNT=$[COUNT+1]
		if [ $COUNT -gt 10 ]
		then
			echo "Error: Timeout while waiting for webserver." 1>&2
			exit 1
		fi
	done
}
