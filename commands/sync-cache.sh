#!/bin/bash

set +e

if [ "$DRUPAL_TI_SAVE_CACHE" = "1" ]
then
	echo "Detecting differences:"

	# Use a clean variant.
        DRUPAL_TI_CACHE_DIR_CLEAN=$(cd $DRUPAL_TI_CACHE_DIR; pwd)

	# Ensure our sync file does not interfere.
        mkdir -p "$DRUPAL_TI_CACHE_DIR_CLEAN.old"
	rm -f "$DRUPAL_TI_CACHE_DIR_CLEAN.old/x-drupal-ti-cache"

	# Use rsync comparison as its very fast.
	touch /tmp/drupal-ti-cache.txt
	rsync --delete -aincO "$DRUPAL_TI_CACHE_DIR_CLEAN" "$DRUPAL_TI_CACHE_DIR_CLEAN.old/" | egrep -v '^\.' | tee /tmp/drupal-ti-cache.txt
	RC="1"
	egrep -q '^' /tmp/drupal-ti-cache.txt || RC=""

	# Touch a file if there are differences.
	test -z "$RC" || touch "$DRUPAL_TI_CACHE_DIR_CLEAN/x-drupal-ti-cache"
fi
exit 0
