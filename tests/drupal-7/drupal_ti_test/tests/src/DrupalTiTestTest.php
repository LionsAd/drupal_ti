<?php

/**
 * @file
 * Contains \Drupal\Tests\drupal_ti_test\DrupalTiTestTest;
 */

namespace Drupal\Tests\drupal_ti_test;

use Drupal\drupal_ti_test\DrupalTiTest;

/**
 * @coversDefaultClass \Drupal\drupal_ti_test\DrupalTiTest
 */
class DrupalTiTestTest extends \PHPUnit_Framework_TestCase {

  /**
   * @covers ::bar
   */
  public function test_bar() {
    $test = new DrupalTiTest();
    $this->assertEquals('foo', $test->bar());
  }
}
