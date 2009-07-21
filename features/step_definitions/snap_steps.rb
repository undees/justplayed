Given /^the following snaps:$/ do
  |snaps_table|

  app.snaps = snaps_from_table(snaps_table, :with_timestamp)
end

Given /^a current time of (.*)$/ do
  |time|

  app.time = time
end

When /^I press (.*)$/ do
  |station|

  app.snap station
end

When /^I look up my snaps$/ do
  app.lookup_snaps
end

When /^I restart the app$/ do
  app.restart
end

When /^I delete all my snaps$/ do
  app.delete_all
end

When /^I (.*) my choice$/ do
  |pick|

  app.answer('confirm' == pick)
end

Then /^the list of snaps should be empty$/ do
  app.snaps.should be_empty
end

Then /^I should see the following snaps:$/ do
  |snaps_table|

  need_links = snaps_table.headers.include? 'link'
  actual = app.snaps.map {|h| h.delete(:link) unless need_links; h}

  actual.should == snaps_from_table(snaps_table)
end
