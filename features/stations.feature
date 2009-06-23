Feature: Stations
  In order to keep my day interesting
  As a radio listener with varied tastes
  I want to track songs from many stations

  Scenario: Empty list
    Given a list of radio stations ""
    Then I should be invited to press Locate

  Scenario: Looking up stations
    Given a test server
    When I look up my stations
    Then I should see the stations "KNRK,KOPB"

  @restart
  Scenario: Remembering stations
    Given a list of radio stations "KBOO,KINK"
    And a test server
    When I restart the app
    Then I should see the stations "KBOO,KINK"

  Scenario: Deleting stations
    Given a list of radio stations "KNRK,KOPB"
    When I delete the first station
    Then I should see the stations "KOPB"
