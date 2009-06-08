Feature: Snaps
  In order to find out what song is playing
  As a radio listener without a mic or data
  I want to remember songs for later lookup

  Scenario: Snapping a song
    Given a list of radio stations "KNRK"
    And a current time of 23:45
    Then the list of snaps should be empty
    When I press KNRK
    Then I should see the following snaps:
      | station | time     |
      | KNRK    | 11:45 PM |

  @restart
  Scenario: Remembering snaps
    Given the following snaps:
      | title | subtitle | link |
      | KBOO  | 5:03 AM  | no   |
      | Stand | R.E.M.   | yes  |
    When I restart the app
    Then I should see the following snaps:
      | title | subtitle | link |
      | KBOO  | 5:03 AM  | no   |
      | Stand | R.E.M.   | yes  |

  Scenario: Deleting snaps
    Given the following snaps:
      | station | time    |
      | KNRK | 12:01 AM |
      | KUFO | 12:00 AM |
    When I delete all my snaps
    And I confirm my choice
    Then the list of snaps should be empty

  Scenario: Cancelling a deletion
    Given the following snaps:
      | station | time    |
      | KNRK | 12:01 AM |
      | KUFO | 12:00 AM |
    When I delete all my snaps
    And I cancel my choice
    Then I should see the following snaps:
      | station | time    |
      | KNRK | 12:01 AM |
      | KUFO | 12:00 AM |
