#!/bin/bash
# @file
# PHP Unit integration - Before Script step.

set -e $DRUPAL_TI_DEBUG

if [ -n "$DRUPAL_TI_COVERAGE_FILE" ]
then
	mkdir -p $(dirname "$DRUPAL_TI_COVERAGE_FILE")
fi
