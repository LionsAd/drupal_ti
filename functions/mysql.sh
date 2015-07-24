#!/bin/bash

#
# Optimizes mysql for running on travis-ci.
#
function drupal_ti_optimize_mysql() {
	# Increase the MySQL connection timeout on the PHP end.
	if [ -n "$TRAVIS_PHP_VERSION" -a "$TRAVIS_PHP_VERSION" != 'hhvm' ]
	then
		# HHVM is in a different directory and handled ourselves.
		echo "mysql.connect_timeout=3000" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
		echo "default_socket_timeout=3000" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
	fi

	# Increase the MySQL server timeout.
	mysql -e "SET GLOBAL wait_timeout = 36000;"

	# The max-allowed packet size does only grow when a request uses
	# the packet size, so it is safe to set it to a high number. In this
	# case 32 MB.
	mysql -e "SET GLOBAL max_allowed_packet = 33554432;"
}
