<?php
/**
 * @file
 * Contains \Drupal\drupal_ti_test\Tests\DrupalTiTestTest.
 */
namespace Drupal\drupal_ti_test\Tests;

use Drupal\simpletest\WebTestBase;
use Drupal\drupal_ti_test\DrupalTiTest;

/**
 * Tests the DrupalTiTest implementation of the drupal_ti_test module.
 *
 * @group drupal_ti_test_group
 *
 * @codeCoverageIgnore
 */
class DrupalTiTestTest extends WebTestBase {

  /**
   * Modules to enable.
   *
   * @var array
   */
  public static $modules = array('drupal_ti_test', 'node');

  /**
   * The basic functionality of the DrupalTiTest class.
   */
  public function testDrupalTiTest() {
    $test = new DrupalTiTest();
    $this->assertEqual('foo', $test->bar(), "Bar function of DrupalTiTest() returns foo.");
    //$this->assertEqual('foo', 'bar', 'This test will fail.');
    $this->drupalGet('<front>');
    $this->assertResponse(200, 'Front page exists.');
    $this->assertRaw('Drupal');

    // Test that login works.
    $admin_user = $this->drupalCreateUser(array('access content'));
    $this->drupalLogin($admin_user);
  }
}

