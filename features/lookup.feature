Feature: Lookup
  In order to find out what songs I heard earlier
  As a radio listener with network access
  I want to look up the songs I bookmarked

  Scenario: Looking up a snap
    Given a list of radio stations
    And a server at http://localhost:4567/:time
    And the following snaps:
      | station | time     |
      | KNRK    | 12:00 PM |
    When I look up my snaps
    Then I should see the following songs:
      | artist           | title                |
      | Jane's Addiction | Been Caught Stealing |
