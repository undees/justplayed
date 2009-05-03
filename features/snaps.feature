Feature: Snaps
  In order to find out what song is playing
  As a radio listener without a mic or data
  I want to remember songs for later lookup

  Scenario: Snapping a song
    Given a list of radio stations
    And a current time of 23:45
    Then the list of snaps should be empty
    When I press KNRK
    Then I should see the following snaps:
      | station | time     |
      | KNRK    | 11:45 PM |

  Scenario: Remembering snaps
    Given the following snaps:
      | station | time    |
      | KBOO    | 5:03 AM |
      | KOPB    | 2:17 PM |
    When I restart the app
    Then I should see the following snaps:
      | station | time    |
      | KBOO    | 5:03 AM |
      | KOPB    | 2:17 PM |
