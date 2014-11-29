#!/bin/bash
# Simple script to install dependencies for travis-ci running.

set -e $DRUPAL_TI_DEBUG

# install php packages required for running a web server from drush on php 5.3
PHP_VERSION=$(phpenv version-name)
if [ "$PHP_VERSION" = "5.3" ]
then
	sudo apt-get update > /dev/null
	sudo apt-get install -y --force-yes php5-cgi php5-mysql
fi

# install drush globally
composer global require drush/drush:6.*
