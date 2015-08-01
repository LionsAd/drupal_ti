@api
Feature: Drupal-specific steps
  In order to prove that the drupal driver is working properly
  As a developer
  I need to be able to use the steps provided here

  Scenario: drupal is bootstraped
    Given I am logged in as a user with the "authenticated user" role
    Then I should see "Log out"

