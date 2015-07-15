#!/bin/bash

set +e

if [ -n "$DRUPAL_TI_LOAD_CACHE" ]
then
	while [ $# -gt 0 ]
	do
		DIR="$1"
		SOURCE=${!DIR}
		mkdir -p "$DRUPAL_TI_CACHE_DIR/$DIR/"
		rsync -a "$DRUPAL_TI_CACHE_DIR/$DIR/" "$SOURCE/"
		shift
	done
fi
exit 0
