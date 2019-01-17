#!/bin/bash
# Simple script to install dependencies for travis-ci running.

set -e $DRUPAL_TI_DEBUG

# Ensure drush webserver can be started for PHP 5.3 / HHVM
drupal_ti_ensure_php_for_drush_webserver

# Ensure that drush is installed.
drupal_ti_ensure_drush

# Optimize MySQL timeout and max packet size.
drupal_ti_optimize_mysql
