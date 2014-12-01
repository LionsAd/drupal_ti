Feature: Test DrupalContext
  In order to prove the Drupal context using the blackbox driver is working properly
  As a developer
  I need to use the step definitions of this context

  @javascript
  Scenario: Test the ability to find a heading in a region
    Given I am on the homepage
    When I click "Home"
    Then I should see "Home"
