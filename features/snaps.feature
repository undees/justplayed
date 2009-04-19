Feature: Snaps
  In order to find out what song is playing
  As a radio listener without a mic or data
  I want to remember songs for later lookup

  Scenario: Snapping a song
    Given a list of radio stations
    Then the list of snaps should be empty
    When I press KNRK
    Then I should see the following snaps:
      | station | time |
      | KNRK    | now  |
