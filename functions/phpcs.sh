#!/usr/bin/env bash
# @file
# Common functionality for installing phpcs.

#
# Ensures that phpcs is installed.
#
function drupal_ti_ensure_phpcs() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-phpcs-installed" ]
	then
		return
	fi

	# Check if phpcs is already available.
	PHPCS=$(which phpcs || echo "")

	if [ -z "$PHPCS" ]
	then
		# Install phpcs globally.
		echo "Installing phpcs: $DRUPAL_TI_PHPCS_VERSION"
		composer global require --no-interaction "$DRUPAL_TI_PHPCS_VERSION" "$DRUPAL_TI_DRUPAL_CODER_VERSION"
	else
		echo "phpcs $DRUPAL_TI_PHPCS_VERSION is already installed."
		composer global install --no-interaction
	fi

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-phpcs-installed"
}

#
# Ensures that drupal/coder is installed.
#
function drupal_ti_ensure_drupal_coder() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-drupal_coder-installed" ]
	then
		return
	fi

	# Check if drupal/coder is already available.
	DRUPAL_CODER=$(composer info --no-interaction drupal/coder || echo "")

	if [ -z "$DRUPAL_CODER" ]
	then
		# Install drupal/coder globally.
		echo "Installing drupal/coder: $DRUPAL_TI_DRUPAL_CODER_VERSION"
		composer global require --no-interaction "$DRUPAL_TI_DRUPAL_CODER_VERSION"
	else
		echo "phpcs $DRUPAL_TI_DRUPAL_CODER_VERSION is already installed."
		composer global install --no-interaction
	fi

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-drupal_coder-installed"
}
