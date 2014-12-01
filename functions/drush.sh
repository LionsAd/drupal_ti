#!/bin/bash
# @file
# Common functionality for installing drush.

#
# Ensures that the right drush version is installed.
#
function drupal_ti_ensure_drush() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-drush-installed" ]
	then
		return
	fi

	# install drush globally
	echo "Installing drush: $DRUPAL_TI_DRUSH_VERSION"
	composer global require "$DRUPAL_TI_DRUSH_VERSION"

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-drush-installed"
}
