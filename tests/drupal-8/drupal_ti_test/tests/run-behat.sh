#!/bin/bash
# @file
# Simple script to load composer and run behat tests.

set -e

DIR=$(dirname $0)
cd $DIR
cd ./behat
test -f "./vendor/bin/behat" || composer install --no-interaction --prefer-source --dev
./vendor/bin/behat "$@"
