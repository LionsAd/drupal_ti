#!/bin/bash
# Simple script to install drupal for travis-ci running.

set -e $DRUPAL_TI_DEBUG

# Ensure the right Drupal version is downloaded.
drupal_ti_ensure_drupal

# Change directory to Drupal core directory.
cd drupal

# Ensure the module is linked into the code base.
drupal_ti_ensure_module_linked
