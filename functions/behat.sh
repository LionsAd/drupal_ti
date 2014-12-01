#!/bin/bash
# @file
# Common functionality for setting up behat.

#
# Ensures that xvfb is started.
#
function drupal_ti_ensure_xvfb() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-xvfb-running" ]
	then
		return
	fi

	# Run a virtual frame buffer server.
	sudo /etc/init.d/xvfb start
	sleep 3

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-xvfb-running"
}

#
# Ensures that selenium is running.
#
function drupal_ti_ensure_selenium() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-selenium-running" ]
	then
		return
	fi

	cd "$TRAVIS_BUILD_DIR/.."
	mkdir -p selenium-server
	cd selenium-server

	# @todo Make version configurable.
	http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar
	java -jar selenium-server-standalone-2.44.0.jar &
	sleep 5
	touch "$TRAVIS_BUILD_DIR/../drupal_ti-selenium-running"
}

function drupal_ti_replace_behat_vars() {
	# Create a dynamic script.
	{
		echo "#!/bin/bash"
		echo "cat <<EOF > behat.yml"
		# @todo Make filename configurable.
		cat behat.yml.dist
		echo "EOF"
	} >> .behat.yml.sh
}
