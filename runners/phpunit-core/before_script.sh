#!/bin/bash
# Simple script to install drupal for travis-ci running.

set -e $DRUPAL_TI_DEBUG

# Ensure the right Drupal version is downloaded.
drupal_ti_ensure_drupal

# Ensure the module is linked into the code base.
drupal_ti_ensure_module_linked

# Ensure server is running for Functional tests
drupal_ti_run_server
