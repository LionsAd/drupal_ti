# drupal\_ti - Travis Integration for Drupal modules

[![Build Status](https://travis-ci.org/LionsAd/drupal_ti.svg?branch=master)](https://travis-ci.org/LionsAd/drupal_ti)

# Versions

[![Latest Stable Version](https://poser.pugx.org/lionsad/drupal_ti/v/stable)](https://packagist.org/packages/lionsad/drupal_ti) [![Total Downloads](https://poser.pugx.org/lionsad/drupal_ti/downloads)](https://packagist.org/packages/lionsad/drupal_ti) [![Latest Unstable Version](https://poser.pugx.org/lionsad/drupal_ti/v/unstable)](https://packagist.org/packages/lionsad/drupal_ti) [![License](https://poser.pugx.org/lionsad/drupal_ti/license)](https://packagist.org/packages/lionsad/drupal_ti)

### Welcome!

Welcome and thanks for trying drupal\_ti!

This will make it simple to use Travis CI to test your Drupal modules with simpletest and PHPUnit tests.

All you need is to push your drupal.org repository to GitHub, set up the module below, log in to travis-ci.org, set up the repo and you are up and running in no time.

### Setup

Copy .travis.yml.dist to your root folder as .travis.yml and customize the `DRUPAL_TI_MODULE_NAME` global environment variable to match the name of your module.

You will also need to activate one matrix option, based on if you have support for SimpleTest, PHPUnit, Behat or all together:

```yml
env:
  matrix:
    # [[[ SELECT ANY OR MORE OPTIONS ]]]
    - DRUPAL_TI_RUNNERS="phpunit" 
    - DRUPAL_TI_RUNNERS="phpunit simpletest behat" 
```

This example would run PHPUnit as one matrix runner, which gives you results fast, then PHPUnit, SimpleTest and Behat as the slow runner.

If you want to run drupal_ti with a Drupal-8 module, then you need to use:

```yml
- DRUPAL_TI_ENVIROMENT="drupal-8"
```

If you want to run drupal_ti with a Drupal-9 module, then you need to use:

```yml
- DRUPAL_TI_ENVIROMENT="drupal-9"
```

### Using a different tests/ directory.

If your tests/ and composer.json are not in tests/ directory you will want to change:

```yml
before_install:
# Comment this line for different directories, e.g. composer in the root.
#  - cd ./tests
```

### How does it work

drupal\_ti provides a drupal-ti command, which is then called with each stage of Travis CI (e.g. `install`, `before_script`, ...).

By providing different runners in runners/simpletest or runners/phpunit/ the corresponding scripts are executed (e.g. runners/phpunit/script.sh).

Also diffent environments are included from `environments/$DRUPAL_TI_ENVIRONMENT.sh`, which makes it possible to distinguish easily between Drupal 7, Drupal 8 & Drupal 9.

This gives you a modular Travis experience and as such the scripts can be very generic.

Drupal is installed in `$TRAVIS_BUILD_DIR/drupal_travis/drupal` and Drush is available after the `before_script` stage.

### How to customize the default behavior

By using

```yml
- DRUPAL_TI_SCRIPT_DIR_BEFORE="./drupal_ti/before"
- DRUPAL_TI_SCRIPT_DIR_AFTER="./drupal_ti/after"
```

you can define your own scripts from your base directory, and drupal\_ti will call them before and after your main scripts.

This is useful to change default environment variables, e.g. environments/drupal-7.sh defines

```yml
export DRUPAL_TI_DRUSH_VERSION="drush/drush:6.*"
```

but you might want a different version and also override the `drupal_ti_install_drupal` function (as core-quick-drupal command needs drush 6).

Theoretically you can even define multiple by just seperating them with a space or installed via Composer - the possibilities are endless :).

Example:

```yml
- DRUPAL_TI_SCRIPT_DIR_BEFORE="./drupal_ti/before ./vendor/lionsad/drupal_ti_base_cool/drupal_ti/before"
- DRUPAL_TI_SCRIPT_DIR_AFTER="./drupal_ti/after  ./vendor/lionsad/drupal_ti_base_cool/drupal_ti/after"
```

### Adding module dependencies from GitHub repositories

Your module may have several dependencies that are not hosted on Drupal.org. These modules can be added using a custom script and `including` them in the `.travis.yml` file.

In `.travis.yml` you will have a section `before_script`. The default command here installs Drupal and the module we are testing. We can add a command `drupal-ti --include [script]`. This command will load the script first and then run the default `drupal-ti before_script` command.

#### .travis.yml
```yml
before_script:
  # We run our script to add module dependencies
  # This uses git clone over HTTPS because the modules don't currently
  # exist on drupal.org.
  - drupal-ti --include drupal_ti/before/before_script.sh
  - drupal-ti before_script
```

The script path is relative to our `/tests` directory since we moved to that default directory during the `before_install` process.

We can now create our custom script as follows:

#### /tests/drupal_ti/before/before_script.sh
```bash
#!/bin/bash

# Add an optional statement to see that this is running in Travis CI.
echo "running drupal_ti/before/before_script.sh"

set -e $DRUPAL_TI_DEBUG

# Ensure the right Drupal version is installed.
# The first time this is run, it will install Drupal.
# Note: This function is re-entrant.
drupal_ti_ensure_drupal

# Change to the Drupal directory
cd "$DRUPAL_TI_DRUPAL_DIR"

# Create the module directory (only necessary for D7)
# For D7, this is sites/default/modules
# For D8, this is modules
mkdir -p "$DRUPAL_TI_DRUPAL_DIR/$DRUPAL_TI_MODULES_PATH"
cd "$DRUPAL_TI_DRUPAL_DIR/$DRUPAL_TI_MODULES_PATH"

# Manually clone the dependencies
git clone --depth 1 https://github.com/my-project/my-dependency.git
# or with a different branch
git clone --depth 1 --branch 8.x-1.x https://github.com/my-project/my-dependency.git
```

The directory `/tests/drupal_ti/before/` can also be used to add auto-discovered scripts using a more complex pattern `/tests/before/runners/[runner]/[command].sh`. This will, however be limited to a specific runner, while the above `include` pattern will run for all runners.

#### Script with Composer Manager
Composer manager is a popular dependency and one that requires extra work in order to be set up.

```bash
#!/bin/bash

# Add an optional statement to see that this is running in Travis CI.
echo "running drupal_ti/before/before_script.sh"

set -e $DRUPAL_TI_DEBUG

# Ensure the right Drupal version is installed.
# The first time this is run, it will install Drupal.
# Note: This function is re-entrant.
drupal_ti_ensure_drupal

# Change to the Drupal directory
cd "$DRUPAL_TI_DRUPAL_DIR"

# Create the module directory (only necessary for D7)
# For D7, this is sites/default/modules
# For D8, this is modules
mkdir -p "$DRUPAL_TI_DRUPAL_DIR/$DRUPAL_TI_MODULES_PATH"
cd "$DRUPAL_TI_DRUPAL_DIR/$DRUPAL_TI_MODULES_PATH"

# Manually clone the dependencies
git clone --depth 1 --branch 8.x-1.x http://git.drupal.org/project/composer_manager.git

# Initialize composer manage
php "$DRUPAL_TI_DRUPAL_DIR/$DRUPAL_TI_MODULES_PATH/composer_manager/scripts/init.php"

# Ensure the module is linked into the code base and enabled.
# Note: This function is re-entrant.
drupal_ti_ensure_module_linked

# Update composer
cd "$DRUPAL_TI_DRUPAL_DIR"
composer drupal-rebuild
composer install --prefer-source
```

### Contributions

Contributions are welcome.

### Drush

For your convenience the `drush site-set` command is set for the Drupal installation, so any Drush commands triggered in your own scripts will be run against the test Drupal instance.
