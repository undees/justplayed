Feature: First launch
  In order to get started right away
  As a brand new user of the app
  I want a server to be specified for me

  Scenario: Empty list
    Given a fresh install
    Then the server should not be empty
