#!/bin/bash

set +e

if [ "$DRUPAL_TI_SAVE_CACHE" = "1" ]
then
	echo "Detecting differences:"

	# Ensure our sync file does not interfere.
        mkdir -p "$DRUPAL_TI_CACHE_DIR.old"
	rm -f "$DRUPAL_TI_CACHE_DIR.old/x-drupal-ti-cache"

	# Use rsync comparison as its very fast.
	touch /tmp/drupal-ti-cache.txt
	rsync --delete -aincO "$DRUPAL_TI_CACHE_DIR" "$DRUPAL_TI_CACHE_DIR.old/" | egrep -v '^\.' | tee /tmp/drupal-ti-cache.txt
	RC="1"
	egrep -q '^' /tmp/drupal-ti-cache.txt || RC=""

	# Touch a file if there are differences.
	test -z "$RC" || touch "$DRUPAL_TI_CACHE_DIR/x-drupal-ti-cache"
fi
exit 0
