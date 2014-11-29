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
php -d sendmail_path=$(which true) ~/.composer/vendor/bin/drush.php --yes core-quick-drupal --profile=testing --no-server --db-url="$DRUPAL_TI_DB_URL" --enable="simpletest" drupal_travis
cd drupal_travis/drupal

# Point service_container into the drupal installation.
ln -sf "$MODULE_DIR" "sites/all/modules/$DRUPAL_TI_MODULE_NAME"

# Enable it to download dependencies.
drush --yes en "$DRUPAL_TI_MODULE_NAME"

# start a web server on port 8080, run in the background; wait for initialization
drush runserver "$DRUPAL_TI_WEBSERVER_URL:$DRUPAL_TI_WEBSERVER_PORT" &
until netstat -an 2>/dev/null | grep -q "$DRUPAL_TI_WEBSERVER_PORT.*LISTEN"
do
	sleep 1
done
