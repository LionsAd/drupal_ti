#!/bin/bash
# @file
# Simple test script to test delegation functionality.

set -e $DRUPAL_TI_DEBUG

echo "It works"

echo "== Testing function calling:"
drupal_ti_test_test_functions
