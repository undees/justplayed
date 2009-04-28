Given /^a list of radio stations$/ do
  @app = WhatJustPlayed.new
end

Given /^the following snaps:$/ do
  |snaps_table|

  @app.snaps = snaps_table.hashes
end

Given /^a current time of (.*)$/ do
  |time|

  @app.time = time
end

Given /^a server at (.*)$/ do
  |url|

  @app.server = url
end

When /^I press (.*)$/ do
  |station|

  @app.snap station
end

When /^I look up my snaps$/ do
  @app.lookup
end

Then /^the list of snaps should be empty$/ do
  @app.snaps.should be_empty
end

Then /^I should see the following snaps:$/ do
  |snaps_table|

  general_table = snaps_table.map_headers \
    'station' => :title,
    'time' => :subtitle

  @app.snaps.should == general_table.hashes
end

Then /^I should see the following songs:$/ do
  |songs_table|

  general_table = songs_table.map_headers \
    'title' => :title,
    'artist' => :subtitle

  @app.snaps.should == general_table.hashes
end
