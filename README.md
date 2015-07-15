# drupal\_ti - Travis Integration for Drupal modules

### Welcome!

Welcome and thanks for trying drupal\_ti!

This will make it simple to use travis to test your drupal modules with simpletest and phpunit tests.

All you need is to push your drupal.org repository to Github, setup the module below, login to travis-ci.org, setup the repo and you are up and running in to time.

### Setup

Copy .travis.yml.dist to your root folder as .travis.yml and customize the DRUPAL\_TI\_MODULE\_NAME global environment variable to match the name of your module.

You will also need to activate one matrix option, based on if you have support for Simpletest, PHPUnit, Behat or all together:

````
env:
  matrix:
    # [[[ SELECT ANY OR MORE OPTIONS ]]]
    - DRUPAL_TI_RUNNERS="phpunit" 
    - DRUPAL_TI_RUNNERS="phpunit simpletest behat" 
````

This example would run phpunit as one matrix runner, which gives you results fast, then phpunit, simpletest and behat as the slow runner.

If you want to run drupal_ti with a Drupal-8 module, then you need to use:

````
- DRUPAL_TI_ENVIROMENT="drupal-8"
````

### Using a different tests/ directory.

If your tests/ and composer.json are not in tests/ directory you will want to change:

````
before_install:
# Comment this line for different directories, e.g. composer in the root.
#  - cd ./tests
````

### How does it work

drupal\_ti provides a drupal-ti command, which is then called with each stage of travis-ci (e.g. install, before_script, ...).

By providing different runners in runners/simpletest or runners/phpunit/ the corresponding scripts are executed (e.g. runners/phpunit/script.sh).

Also diffent environments are included from ````environments/$DRUPAL_TI_ENVIRONMENT.sh````, which makes it possible to distinguish easily between Drupal 7 and 8.

This gives you a modular travis experience and such the scripts can be very generic.

Drupal is installed in $TRAVIS\_BUILD\_DIR/drupal\_travis/drupal and drush is available after before\_script stage.

### How to customize the default behavior

By using

````
- DRUPAL_TI_SCRIPT_DIR_BEFORE="./drupal_ti/before"
- DRUPAL_TI_SCRIPT_DIR_AFTER="./drupal_ti/after"
````

you can define your own scripts from your base directory, and drupal\_ti will call them before and after your main scripts.

This is useful to change default environment variables, e.g. environments/drupal-7.sh defines

````
export DRUPAL_TI_DRUSH_VERSION="drush/drush:6.*"
````

but you might want a different version and also override the drupal_ti_install_drupal function (as core-quick-drupal command needs drush 6).

Theoretically you can even define multiple by just seperating them with a space or installed via composer - the possibilities are endless :).

Example:

````
- DRUPAL_TI_SCRIPT_DIR_BEFORE="./drupal_ti/before ./vendor/lionsad/drupal_ti_base_cool/drupal_ti/before"
- DRUPAL_TI_SCRIPT_DIR_AFTER="./drupal_ti/after  ./vendor/lionsad/drupal_ti_base_cool/drupal_ti/after"
````

Contributions are welcome.

### Status

[![Build Status](https://travis-ci.org/LionsAd/drupal_ti.svg?branch=master)](https://travis-ci.org/LionsAd/drupal_ti)
