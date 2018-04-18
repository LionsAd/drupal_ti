#!/usr/bin/env bash
# @file
# phpcs integration - Script step.

set -e $DRUPAL_TI_DEBUG

ARGS=( $DRUPAL_TI_PHPCS_ARGS )

$HOME/.composer/vendor/bin/phpcs "${ARGS[@]}"
