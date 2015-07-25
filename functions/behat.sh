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
        { /usr/bin/Xvfb $DISPLAY -ac -screen 0 "$DRUPAL_TI_BEHAT_SCREENSIZE_COLOR" 2>&1 | drupal_ti_log_output "xvfb"; } &
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

	# @todo Make whole file URL overridable via defaults based on env.
	wget "http://selenium-release.storage.googleapis.com/$DRUPAL_TI_BEHAT_SELENIUM_VERSION/selenium-server-standalone-$DRUPAL_TI_BEHAT_SELENIUM_VERSION.0.jar"
	{ java -jar "selenium-server-standalone-$DRUPAL_TI_BEHAT_SELENIUM_VERSION.0.jar" $DRUPAL_TI_BEHAT_SELENIUM_ARGS 2>&1 | drupal_ti_log_output "selenium" ; } &

        # Wait until selenium has been started.
        drupal_ti_wait_for_service_port 4444

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-selenium-running"
}

#
# Ensures that phantomjs is running.
#
function drupal_ti_ensure_phantomjs() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-phantomjs-running" ]
	then
		return
	fi

	{ phantomjs $DRUPAL_TI_BEHAT_PHANTOMJS_ARGS 2>&1 | drupal_ti_log_output "selenium" ; } &

        # Wait until selenium has been started.
        drupal_ti_wait_for_service_port 4444

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-phantomjs-running"
}

#
# Ensures local bin dir exists and variables are set.
#
function drupal_ti_ensure_bin_dir() {
        # Create bin dir
	(
		cd "$TRAVIS_BUILD_DIR/.."
		mkdir -p "drupal_travis/bin"
	)
        export DRUPAL_TI_BIN_DIR=$(cd "$TRAVIS_BUILD_DIR/../drupal_travis/bin"; pwd)
        export PATH="$DRUPAL_TI_BIN_DIR:$PATH"
}

#
# Ensures that chrome is installed.
#
function drupal_ti_ensure_chrome() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-chrome-installed" ]
	then
		return
	fi

	# @todo Move to defaults API.
	if [ -z "$DRUPAL_TI_BEHAT_CHROME_URL" ]
	then
		DRUPAL_TI_BEHAT_CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
	fi

	drupal_ti_ensure_apt_get
	(
		cd $DRUPAL_TI_DIST_DIR
		wget -O google-chrome-stable_current_amd64.deb "$DRUPAL_TI_BEHAT_CHROME_URL"
		dpkg -x google-chrome-stable_current_amd64.deb .
	)
	drupal_ti_ensure_bin_dir
	cat <<EOF >$DRUPAL_TI_BIN_DIR/chromium-browser
#!/bin/bash

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:"
$DRUPAL_TI_DIST_DIR/opt/google/chrome/google-chrome --no-sandbox "\$@"
EOF
	chmod a+x $DRUPAL_TI_BIN_DIR/chromium-browser
	touch "$TRAVIS_BUILD_DIR/../drupal_ti-chrome-installed"
}

#
# Ensures that chrome driver is installed.
#
function drupal_ti_ensure_chrome_driver() {
	# This function is re-entrant.
	if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-chrome-driver-installed" ]
	then
		return
	fi

	drupal_ti_ensure_bin_dir
	cd $DRUPAL_TI_BIN_DIR

	# @todo Make version configurable.
	wget http://chromedriver.storage.googleapis.com/2.13/chromedriver_linux64.zip
	unzip chromedriver_linux64.zip
	rm -f chromedriver_linux64.zip
	chmod a+x chromedriver
	drupal_ti_ensure_chrome

	touch "$TRAVIS_BUILD_DIR/../drupal_ti-chrome-driver-installed"
}


#
# Ensures that webdriver is running.
#
function drupal_ti_ensure_webdriver() {
        # This function is re-entrant.
        if [ -r "$TRAVIS_BUILD_DIR/../drupal_ti-selenium-running" ]
        then
                return
        fi

	export DRUPAL_TI_BEHAT_PHANTOMJS_ARGS="--webdriver=127.0.0.1:4444"
	export DRUPAL_TI_BEHAT_SELENIUM_ARGS=""

	if [ "$DRUPAL_TI_BEHAT_BROWSER" = "chrome" ]
	then
		drupal_ti_ensure_chrome_driver
		CHROMEDRIVER=$(which chromedriver || echo "")
		DRUPAL_TI_BEHAT_SELENIUM_ARGS="-Dwebdriver.chrome.driver=$CHROMEDRIVER $DRUPAL_TI_BEHAT_SELENIUM_ARGS"
	fi

	case "$DRUPAL_TI_BEHAT_DRIVER" in
		"phantomjs")
			drupal_ti_ensure_phantomjs
		;;
		"selenium"|*)
			drupal_ti_ensure_selenium
		;;
	esac

        touch "$TRAVIS_BUILD_DIR/../drupal_ti-selenium-running"
}


#
# Replaces behat.yml from behat.yml.dist
#
function drupal_ti_replace_behat_vars() {
	# Create a dynamic script.
	{
		echo "#!/bin/bash"
		echo "cat <<EOF > behat.yml"
		cat "$DRUPAL_TI_BEHAT_YML"
		echo "EOF"
	} >> .behat.yml.sh

	# Execute the script.
	. .behat.yml.sh
}
