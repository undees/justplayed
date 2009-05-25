Feature: Stations
  In order to keep my day interesting
  As a radio listener with varied tastes
  I want to track songs from many stations

  Scenario: Station list
    Given a server at http://localhost:4567
    When I look up my stations
    Then I should see the stations "KNRK,KOPB"
