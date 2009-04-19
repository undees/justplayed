Feature: Snaps
  In order to find out what song is playing
  As a radio listener without a mic or data
  I want to remember songs for later lookup

  Scenario: Snapping a song
    Given a list of radio stations
    Then I should see 0 snaps
    When I press KNRK
    Then I should see 1 snap for KNRK now
