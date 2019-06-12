<?php

/**
 * @file
 * Contains \Drupal\Tests\drupal_ti_test\Functional\DrupalTiTestTest;
 */

namespace Drupal\Tests\drupal_ti_test\Functional;

use Drupal\drupal_ti_test\DrupalTiTest;
use Drupal\Tests\BrowserTestBase;

/**
 * @coversDefaultClass \Drupal\drupal_ti_test\DrupalTiTest
 *
 * @group drupal_ti_test
 */
class DrupalTiTestTest extends BrowserTestBase {

  /**
   * Modules to enable.
   *
   * @var array
   */
  public static $modules = ['system', 'user', 'drupal_ti_test'];

  /**
   * @covers ::bar
   */
  public function testBrowserTestBase() {
    $test = new DrupalTiTest();
    $this->assertEquals('foo', $test->bar());
  }
}
