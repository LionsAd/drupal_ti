#!/bin/bash
# Simple script to install drupal for travis-ci running.

set -e $DRUPAL_TI_DEBUG

# Find absolute path to module.
cd "$TRAVIS_BUILD_DIR"
MODULE_DIR=$(pwd)
cd ..

# HHVM env is broken: https://github.com/travis-ci/travis-ci/issues/2523.
PHP_VERSION=`phpenv version-name`
if [ "$PHP_VERSION" = "hhvm" ]
then
	# Create sendmail command, which links to /bin/true for HHVM.
        mkdir -p drupal_travis/bin
        ln -s $(which true) drupal_travis/bin/sendmail
        CWD=$(pwd)
        export PATH="$CWD/drupal_travis/bin:$PATH"
fi

# Create database and install Drupal.
mysql -e "create database $DRUPAL_TI_DB"

mkdir -p "$DRUPAL_TI_DRUPAL_BASE"
cd "$DRUPAL_TI_DRUPAL_BASE"

drupal_ti_install_drupal

cd "$DRUPAL_TI_DRUPAL_DIR"

# Enable simpletest module.
drush --yes en simpletest

# Point service_container into the drupal installation.
ln -sf "$MODULE_DIR" "$DRUPAL_TI_MODULES_PATH/$DRUPAL_TI_MODULE_NAME"

# Enable it to download dependencies.
drush --yes en "$DRUPAL_TI_MODULE_NAME"

drupal_ti_clear_caches

# start a web server on port 8080, run in the background; wait for initialization
drush runserver "$DRUPAL_TI_WEBSERVER_URL:$DRUPAL_TI_WEBSERVER_PORT" &
until netstat -an 2>/dev/null | grep -q "$DRUPAL_TI_WEBSERVER_PORT.*LISTEN"
do
	sleep 1
done
