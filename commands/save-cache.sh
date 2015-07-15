#!/bin/bash

set +e

if [ "$DRUPAL_TI_SAVE_CACHE" = "1" ]
then
	mkdir -p "$DRUPAL_TI_CACHE_DIR"
	DRUPAL_TI_CACHE_DIR_CLEAN=$(cd $DRUPAL_TI_CACHE_DIR; pwd)
	mv "$DRUPAL_TI_CACHE_DIR_CLEAN" "$DRUPAL_TI_CACHE_DIR_CLEAN.old"

	# Sync over specified directories.
        while [ $# -gt 0 ]
        do
                DIR="$1"
                shift
                SOURCE=${!DIR}
                VAR="DRUPAL_TI_CACHE_DIRS_$DIR"
                DIRS_TO_SYNC=${!VAR}

                mkdir -p "$DRUPAL_TI_CACHE_DIR/$DIR/"
		IFS='|'
		for SUBDIR in $DIRS_TO_SYNC
		do
			if [ -d "$SOURCE/$SUBDIR" ]
			then
				mkdir -p "$DRUPAL_TI_CACHE_DIR/$DIR/$SUBDIR/"
				rsync -a "$SOURCE/$SUBDIR" $(dirname "$DRUPAL_TI_CACHE_DIR/$DIR/$SUBDIR/")
			fi
		done
		unset IFS
	done

	# Composer optimizations: Ignore old backups.
	if [ -d "$DRUPAL_TI_CACHE_DIR"/HOME/.composer ]
	then
		rm -f "$DRUPAL_TI_CACHE_DIR"/HOME/.composer/*.phar

		# Delete files that screw up cache detection.
		rm -f "$DRUPAL_TI_CACHE_DIR"/HOME/.composer/vendor/composer/*.php
		rm -f "$DRUPAL_TI_CACHE_DIR"/HOME/.composer/vendor/autoload.php
	fi

	# Drush optimizations: Ignore always changing cache files.
	if [ -d "$DRUPAL_TI_CACHE_DIR"/HOME/.drush/cache/default ]
	then
		rm -f "$DRUPAL_TI_CACHE_DIR"/HOME/.drush/cache/default/*.cache
	fi
fi
exit 0
