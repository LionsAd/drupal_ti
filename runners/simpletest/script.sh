#!/bin/bash
# @file
# Simple script to run the tests via travis-ci.

set -e $DRUPAL_TI_DEBUG

export ARGS=( $DRUPAL_TI_SIMPLETEST_ARGS )

cd "$TRAVIS_BUILD_DIR/../drupal_travis/drupal/"
{ php scripts/run-tests.sh --php $(which php) "${ARGS[@]}" || echo "1 fails"; } | tee /tmp/simpletest-result.txt

egrep -i -v -q "([0-9]+ fails)|(PHP Fatal error)|([0-9]+ exceptions)" /tmp/simpletest-result.txt
