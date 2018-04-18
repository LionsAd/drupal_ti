#!/usr/bin/env bash
# Simple script to install dependencies for travis-ci running.

set -e $DRUPAL_TI_DEBUG

# Ensure that drupal/coder is installed.
drupal_ti_ensure_drupal_coder

# Ensure that phpcs is installed.
drupal_ti_ensure_phpcs
