Given /^a list of radio stations$/ do
  # no-op
end

Given /^the following snaps:$/ do
  |snaps_table|

  hashes = snaps_table.hashes.map do |h|
    {:title => h['title'] || h['station'],
     :subtitle => h['subtitle'] || h['time'] || h['artist'],
     :created_at => (h['time'] ? Chronic.parse(h['time']) : nil)}
  end

  app.snaps = hashes
end

Given /^a current time of (.*)$/ do
  |time|

  app.time = time
end

Given /^a server at (.*)$/ do
  |url|

  app.server = url
end

When /^I press (.*)$/ do
  |station|

  app.snap station
end

When /^I look up my snaps$/ do
  app.lookup
end

When /^I restart the app$/ do
  app.restart
end

Then /^the list of snaps should be empty$/ do
  app.snaps.should be_empty
end

Then /^I should see the following snaps:$/ do
  |snaps_table|

  hashes = snaps_table.hashes.map do |h|
    {:title => h['title'] || h['station'],
     :subtitle => h['subtitle'] || h['time'] || h['artist']}
  end

  app.snaps.should == hashes
end
