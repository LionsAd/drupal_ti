#!/bin/bash
# @file
# Includes the environment and then the given script.

# Include environments from different directories.
for SCRIPT_DIR in $DRUPAL_TI_SCRIPT_DIRS
do
	SCRIPT="$SCRIPT_DIR/environments/$DRUPAL_TI_ENVIRONMENT.sh"
	if [ -x "$SCRIPT" ]
	then
		. "$SCRIPT"
	fi
done


# Include script as if it was called directly.
SCRIPT=$1
shift
. $SCRIPT
