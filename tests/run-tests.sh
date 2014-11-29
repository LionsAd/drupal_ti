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
export DRUPAL_TI_RUNNERS="tests"
/tmp/drupal_ti/bin/drupal-ti script
