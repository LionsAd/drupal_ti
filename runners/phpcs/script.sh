#!/usr/bin/env bash
# @file
# phpcs integration - Script step.

set -e $DRUPAL_TI_DEBUG

if [[ -n $DRUPAL_TI_PHPCS_ARGS ]]; then
  ARGS=( $DRUPAL_TI_PHPCS_ARGS )
else
  ARGS=(
    "--colors"
    "--standard=Drupal,DrupalPractice"
    "--extensions=php,module,inc,install,test,profile,theme,css,info,txt,md"
    "--ignore=node_modules,bower_components,vendor"
    "${TRAVIS_BUILD_DIR}"
  )
fi

$HOME/.composer/vendor/bin/phpcs "${ARGS[@]}"
