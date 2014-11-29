#!/bin/bash
# @file
# PHP Unit integration - Install step.

set -e $DRUPAL_TI_DEBUG

composer install --no-interaction --prefer-source --dev

if [ -n "$DRUPAL_TI_COVERAGE" ]
then
	# Note: This cannot be installed globally.
	composer require --dev "$DRUPAL_TI_COVERAGE"
fi
