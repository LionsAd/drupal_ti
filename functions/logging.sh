#!/bin/bash
# @file
# Functionality for logging output to a file or passing through.

#
# Ensures that the right Drupal version is installed.
#
function drupal_ti_log_output() {
	FILE=$1
	shift

	LOG_OUTPUT=""
        if [ "$DRUPAL_TI_DEBUG_FILE_OUTPUT" = "all" ]
        then
		LOG_OUTPUT="all"
	else
		case "$DRUPAL_TI_DEBUG_FILE_OUTPUT" in *"$FILE"*) LOG_OUTPUT="$FILE" ;; esac
	fi

	mkdir -p /tmp/travis-logs
	LOGFILE="/tmp/travis-logs/$FILE.log"

	if [ -n "$LOG_OUTPUT" ]
	then
		echo "Logging output of '$FILE' channel to $LOGFILE and stdout."
		tee "$LOGFILE" | while read LINE
		do
			echo "... $FILE>   $LINE"
		done
	else
		echo "Logging output of '$FILE' channel to $LOGFILE."
		cat - > "$LOGFILE"
	fi
}
