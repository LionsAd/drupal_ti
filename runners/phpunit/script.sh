#!/bin/bash
# @file
# PHP Unit integration - Script step.

set -e $DRUPAL_TI_DEBUG

ARGS=( $DRUPAL_TI_PHPUNIT_ARGS )
if [ -n "$DRUPAL_TI_COVERAGE_FILE" ]
then
	ARGS=( "${ARGS[@]}" "--coverage-clover" "$DRUPAL_TI_COVERAGE_FILE")
fi

./vendor/bin/phpunit "${ARGS[@]}"
