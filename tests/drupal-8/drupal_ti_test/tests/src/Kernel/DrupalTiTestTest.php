<?php

/**
 * @file
 * Contains \Drupal\Tests\drupal_ti_test\Kernel\DrupalTiTestTest;
 */

namespace Drupal\Tests\drupal_ti_test\Kernel;

use Drupal\drupal_ti_test\DrupalTiTest;
use Drupal\KernelTests\KernelTestBase;

/**
 * @coversDefaultClass \Drupal\drupal_ti_test\DrupalTiTest
 *
 * @group drupal_ti_test
 */
class DrupalTiTestTest extends KernelTestBase {

  /**
   * Modules to enable.
   *
   * @var array
   */
  public static $modules = ['system', 'user', 'drupal_ti_test'];

  /**
   * {@inheritdoc}
   */
  protected function setUp() {
    parent::setUp();

    // Do something with the database.
    $this->installSchema('system', 'router');
  }

  /**
   * @covers ::bar
   */
  public function testKernelTestBase() {
    $test = new DrupalTiTest();
    $this->assertEquals('foo', $test->bar());
  }
}
