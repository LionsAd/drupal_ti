#!/bin/bash
# @file
# Simple script to run the tests.

set -e

# Goto current directory.
DIR=$(dirname $0)
cd $DIR

drush -y en simpletest drupal_ti_test
drush test-run "DrupalTi Test" "$@"
