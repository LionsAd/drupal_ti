#!/bin/bash
# @file
# Simple script to run the tests via travis-ci.

set -e $DRUPAL_TI_DEBUG

export ARGS=( $DRUPAL_TI_SIMPLETEST_ARGS )

if [ -n "$DRUPAL_TI_SIMPLETEST_GROUP" ]
then
        ARGS=( "${ARGS[@]}" "$DRUPAL_TI_SIMPLETEST_GROUP" )
fi


cd "$TRAVIS_BUILD_DIR/../drupal_travis/drupal/"
{ php scripts/run-tests.sh --php $(which php) "${ARGS[@]}" || echo "1 fails"; } | tee /tmp/simpletest-result.txt

egrep -i -q "([0-9]+ fails)|(PHP Fatal error)|([0-9]+ exceptions)" /tmp/simpletest-result.txt && exit 1
exit 0
