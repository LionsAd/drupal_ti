#!/bin/bash
# @file
# Simple script to install composer dependencies.

set -e

DIR=$(dirname $0)
cd $DIR
composer self-update
composer install --no-interaction --prefer-source --dev
