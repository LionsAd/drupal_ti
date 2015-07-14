#!/bin/bash
# @file
# Common functionality for apt tasks.

# Ensure apt-get can be used without sudo.
function drupal_ti_ensure_apt_get() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-apt-get-installed" ]
	then
		return
	fi

	mkdir -p "$DRUPAL_TI_DIST_DIR/etc/apt/"
	mkdir -p "$DRUPAL_TI_DIST_DIR/var/cache/apt/archives/partial"
	mkdir -p "$DRUPAL_TI_DIST_DIR/var/lib/apt/lists/partial"

	cat <<EOF >"$DRUPAL_TI_DIST_DIR/etc/apt/apt.conf"
Dir::Cache "$DRUPAL_TI_DIST_DIR/var/cache/apt";
Dir::State "$DRUPAL_TI_DIST_DIR/var/lib/apt";
EOF
	touch "$TRAVIS_BUILD_DIR/../drupal_ti-apt-get-installed"
}

# Ensure apt-get can be used without sudo in limited mode.
function drupal_ti_apt_get() {
	drupal_ti_ensure_apt_get
	if [ "$1" = "install" ]
	then
		export ARGS=( "$@" )
		ARGS[0]="download"
		(
			cd "$DRUPAL_TI_DIST_DIR"
			apt-get -c "$DRUPAL_TI_DIST_DIR/etc/apt/apt.conf" "${ARGS[@]}" || true
			for i in *.deb
			do
				dpkg -x "$i" .
			done
			rm -f *.deb
		)
	else
		apt-get -c "$DRUPAL_TI_DIST_DIR/etc/apt/apt.conf" "$@" || true
	fi
}
