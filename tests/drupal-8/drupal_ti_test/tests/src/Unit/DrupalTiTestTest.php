<?php

/**
 * @file
 * Contains \Drupal\Tests\drupal_ti_test\Unit\DrupalTiTestTest;
 */

namespace Drupal\Tests\drupal_ti_test\Unit;

use Drupal\drupal_ti_test\DrupalTiTest;

/**
 * @coversDefaultClass \Drupal\drupal_ti_test\DrupalTiTest
 *
 * @group drupal_ti_test
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
