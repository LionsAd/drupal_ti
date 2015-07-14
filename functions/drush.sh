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

	# Check if drush is already available.
	DRUSH=$(which drush || echo "")

	if [ -z "$DRUSH" ]
	then
		# install drush globally
		echo "Installing drush: $DRUPAL_TI_DRUSH_VERSION"
		composer global require --no-interaction "$DRUPAL_TI_DRUSH_VERSION"
	else
		echo "Drush $DRUPAL_TI_DRUSH_VERSION is already installed."
		composer global install --no-interaction
	fi

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-drush-installed"
}
