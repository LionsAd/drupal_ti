#!/bin/bash
# Simple script to install drupal for travis-ci running.

set -e $DRUPAL_TI_DEBUG

# Ensure that the GIT configurations have been set.
drupal_ti_ensure_git

# Ensure the right Drupal version is installed.
# The first time this is run, it will install Drupal.
# Note: This function is re-entrant.
drupal_ti_ensure_drupal

# Ensure that phpcov is installed.
drupal_ti_ensure_phpcov

# Change to the Drupal directory
cd "$DRUPAL_TI_DRUPAL_DIR"

# Create the the module directory (only necessary for D7)
# For D7, this is sites/default/modules
mkdir -p "$DRUPAL_TI_DRUPAL_DIR/$DRUPAL_TI_MODULES_PATH"
cd "$DRUPAL_TI_DRUPAL_DIR/$DRUPAL_TI_MODULES_PATH"

# Enable simpletest module.
cd "$DRUPAL_TI_DRUPAL_DIR"
drush --yes en simpletest

# Ensure the module is linked into the code base and enabled.
drupal_ti_ensure_module

# Clear caches and run a web server.
drupal_ti_clear_caches
drupal_ti_run_server

# Make sure that we aren't using a symbolic link of the module.
drupal_ti_simpletest_coverage_install_module