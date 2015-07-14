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

	OPTIONS=()

	# Set PHP CGI explicitly to php5-cgi full path.
	PHP_VERSION=$(phpenv version-name)
	if [ "$PHP_VERSION" = "5.3" -o "$PHP_VERSION" = "hhvm" ]
	then
		PHP5_CGI=$(which php5-cgi)
		OPTIONS=( "${OPTIONS[@]}" --php-cgi="$PHP5_CGI")
	fi

	(
		mkdir -p $HOME/drush
		cd $HOME/drush
		composer require --no-interaction --prefer-source "drush/drush:6.5"
       )

	# start a web server on port 8080, run in the background; wait for initialization
	{ $HOME/drush/vendor/bin/drush runserver "${OPTIONS[@]}" "$DRUPAL_TI_WEBSERVER_URL:$DRUPAL_TI_WEBSERVER_PORT" 2>&1 | drupal_ti_log_output "webserver" ; } &

	# Wait until drush server has been started.
	drupal_ti_wait_for_service_port "$DRUPAL_TI_WEBSERVER_PORT"
	touch "$TRAVIS_BUILD_DIR/../drupal_ti-drush-server-running"
}

#
# Ensure hhvm runs in daemon mode.
#
function drupal_ti_ensure_hhvm_fastcgi() {
	hhvm --mode daemon -vServer.Type=fastcgi -vServer.FileSocket=/tmp/php-fastcgi.sock -vLog.File=/tmp/hhvm.log
	{ tail -f /tmp/hhvm.log | drupal_ti_log_output "hhvm-fastcgi"; } &
}

#
# Ensure that PHP FPM runs.
#
function drupal_ti_ensure_php_fpm() {
	# @todo Fix differently.
	export DRUSH_BASE_PATH="$HOME/drush/vendor/drush/drush"

	# PHP-FPM
	export DRUPAL_TI_PHP_FPM_CONF="$TRAVIS_BUILD_DIR/../php-fpm.conf"
cat <<EOF >"$DRUPAL_TI_PHP_FPM_CONF"
error_log = /tmp/fpm-php.log

[www]
user = travis
group = travis

listen = /tmp/php-fastcgi.sock
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

php_value[auto_prepend_file] = $DRUSH_BASE_PATH/commands/runserver/runserver-prepend.php
EOF
	{ php-fpm -F -y "$DRUPAL_TI_PHP_FPM_CONF" | drupal_ti_log_output "php-fpm"; } &
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
		return
	fi
	if [ "$PHP_VERSION" = "hhvm" ]
	then
		drupal_ti_ensure_hhvm_fastcgi
	else
		drupal_ti_ensure_php_fpm
	fi
	echo "HVVM setup ..."

	drupal_ti_apt_get update >/dev/null 2>&1
	drupal_ti_apt_get install libfcgi0ldbl

        cat <<EOF >$DRUPAL_TI_DIST_DIR/usr/bin/php5-cgi
#!/bin/bash

export DOCUMENT_ROOT="$DRUPAL_TI_DRUPAL_DIR"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$DRUPAL_TI_DIST_DIR/usr/lib"
$DRUPAL_TI_DIST_DIR/usr/bin/cgi-fcgi -bind -connect /tmp/php-fastcgi.sock
EOF
        chmod a+x $DRUPAL_TI_DIST_DIR/usr/bin/php5-cgi
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
