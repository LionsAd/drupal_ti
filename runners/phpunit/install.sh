#!/bin/bash
# @file
# PHP Unit integration - Install step.

set -e $DRUPAL_TI_DEBUG

composer install --no-interaction --prefer-source --dev

if [ -n "$DRUPAL_TI_COVERAGE" ]
then
	# Note: This cannot be installed globally.
	if [ -x "./vendor/bin/coveralls" ]
	then
		echo "Coveralls is already installed."
		composer install --no-interaction
	else
		composer require --no-interaction --dev "$DRUPAL_TI_COVERAGE"
		# Update the lock file, too.
		composer update --lock
	fi
fi
