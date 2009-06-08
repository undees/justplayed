Feature: Network
  In order to get the network running
  As a new user of the app
  I want information on status and progress

  @restart
  Scenario: Default server
    Given a fresh install
    Then the server should not be empty

  Scenario: Missing server
    Given a server at http://localhost:55555
    When I try looking up my stations
    Then I should see a network warning
