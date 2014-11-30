#!/bin/bash
# @file
# Simple file to run a test-run.

SCRIPT_DIR=$(cd $(dirname $0)/..; pwd)

# Setup a symlink.
mkdir -p /tmp/drupal_ti/bin
export PATH="$PATH:/tmp/drupal_ti/bin"
rm -f /tmp/drupal_ti/bin/drupal-ti
ln -sf "$SCRIPT_DIR/drupal-ti" /tmp/drupal_ti/bin/

# Setup runners.
export DRUPAL_TI_RUNNERS="success"
/tmp/drupal_ti/bin/drupal-ti script && echo "- Test succeeed as expected." || exit 1

export DRUPAL_TI_RUNNERS="failure"
/tmp/drupal_ti/bin/drupal-ti script && exit 1 || echo "- Test failed as expected."

export DRUPAL_TI_RUNNERS="simpletest-failure"
/tmp/drupal_ti/bin/drupal-ti script && exit 1 || echo "- Simpletest failed as expected."

export DRUPAL_TI_RUNNERS="success failure"
/tmp/drupal_ti/bin/drupal-ti script exit 1 || echo "- Success / Failure failed properly."

export DRUPAL_TI_RUNNERS="failure success"
/tmp/drupal_ti/bin/drupal-ti script exit 1 || echo "- Failure / Success failed properly."
