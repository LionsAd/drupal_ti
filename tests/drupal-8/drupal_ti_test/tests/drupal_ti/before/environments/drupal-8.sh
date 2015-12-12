#!/bin/bash
# @file
# Drupal-8 environment variables.

export DRUPAL_TI_SIMPLETEST_GROUP="drupal_ti_test_group";

# Override the install profile for Drupal 8.
# This is needed as behat does not work with minimal right now.
export DRUPAL_TI_INSTALL_PROFILE="standard";
