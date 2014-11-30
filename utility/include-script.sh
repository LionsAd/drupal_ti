#!/bin/bash
# @file
# Includes the environment and then the given script.

# Include environment
. "$DRUPAL_TI_ENVIRONMENT_INCLUDE"

# Include script as if it was called directly.
SCRIPT=$1
shift
. $SCRIPT
