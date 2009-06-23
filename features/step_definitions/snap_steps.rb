Given /^the following snaps:$/ do
  |snaps_table|

  hashes = snaps_table.hashes.map do |h|
    r = {:title => h['title'] || h['station'],
         :subtitle => h['subtitle'] || h['time'] || h['artist'],
         :created_at => ((h['time'] || h['link'] == 'yes') ? Chronic.parse(h['time'] || h['subtitle']) : nil)}
    r[:link] = (h['link'] == 'yes') if h['link']
    r
  end

  app.snaps = hashes
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

  hashes = snaps_table.hashes.map do |h|
    r = {:title => h['title'] || h['station'],
         :subtitle => h['subtitle'] || h['time'] || h['artist']}

    r[:link] = (h['link'] == 'yes') if h['link']
    r
  end

  actual = app.snaps
  unless snaps_table.headers.include? 'link'
    actual.map! {|h| h.delete :link; h}
  end

  actual.should == hashes
end
