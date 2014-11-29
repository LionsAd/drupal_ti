# drupal\_ti - Travis Integration for Drupal modules

### Welcome!

Welcome and thanks for trying drupal\_ti!

This will make it simple to use travis to test your drupal modules with simpletest and phpunit tests.

All you need is to push your drupal.org repository to Github, setup the module below, login to travis-ci.org, setup the repo and you are up and running in to time.

### Setup

Copy .travis.yml.dist to your root folder as .travis.yml and customize the DRUPAL\_TI\_MODULE\_NAME global environment variable to match the name of your module.

You will also need to activate one matrix option, based on if you have support for simpletest, phpunit or both:

````
env:
  matrix:
    # [[[ SELECT ANY OR MORE OPTIONS ]]]
    - DRUPAL_TI_RUNNERS="phpunit" 
    - DRUPAL_TI_RUNNERS="phpunit simpletest" 
````

This example would run phpunit as one matrix runner, which gives you results fast, then both phpunit and simpletest as the slow runner.

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

This gives you a modular travis experience and such the scripts can be very generic.

Drupal is installed in $TRAVIS\_BUILD\_DIR/drupal\_travis/drupal and drush is available after before\_script stage.

### Roadmap

- Support behat running with phantomjs and selenium.

Contributions are welcome.

### Status

[![Build Status](https://travis-ci.org/LionsAd/drupal_ti.svg?branch=master)](https://travis-ci.org/LionsAd/drupal_ti)
