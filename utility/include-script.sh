#!/bin/bash
# @file
# Includes the environment and then the given script.

# Include functions and environments from different directories.
for SCRIPT_DIR in $DRUPAL_TI_SCRIPT_DIRS
do
	if [ -d "$SCRIPT_DIR/functions" ]
	then
		for SCRIPT in "$SCRIPT_DIR/functions"/*.sh
		do
			if [ -r "$SCRIPT" ]
			then
				. "$SCRIPT"
			fi
		done
	fi

	SCRIPT="$SCRIPT_DIR/environments/$DRUPAL_TI_ENVIRONMENT.sh"
	if [ -r "$SCRIPT" ]
	then
		. "$SCRIPT"
	fi
done


# Include script as if it was called directly.
SCRIPT=$1
shift
. $SCRIPT
