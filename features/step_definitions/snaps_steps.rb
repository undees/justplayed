Given /^a list of radio stations$/ do
  @app = WhatJustPlayed.new
end

When /^I press (.*)$/ do
  |station|

  pending
end

Then /^the list of snaps should be empty$/ do
  @app.snaps.should be_empty
end

Then /^I should see the following snaps:$/ do
  |snaps_table|

  pending
end
