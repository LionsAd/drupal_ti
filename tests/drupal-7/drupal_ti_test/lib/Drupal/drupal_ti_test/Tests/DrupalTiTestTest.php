<?php
/**
 * @file
 * Contains \Drupal\drupal_ti_test\Tests\DrupalTiTestTest.
 */
namespace Drupal\drupal_ti_test\Tests;

use Drupal\drupal_ti_test\DrupalTiTest;

/**
 * Tests the DrupalTiTest implementation of the drupal_ti_test module.
 */
class DrupalTiTestTest extends \DrupalWebTestCase {
  /**
   * The profile to install as a basis for testing.
   *
   * @var string
   */
  protected $profile = 'testing';

  /**
   * {@inheritdoc}
   */
  public static function getInfo() {
    return array(
      'name' => 'Drupal Travis Integration - Test module',
      'description' => 'Tests the Drupal Travis Integration Test module.',
      'group' => 'DrupalTi Test',
    );
  }

  protected function setUp() {
    parent::setUp(array('drupal_ti_test'));
  }

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

