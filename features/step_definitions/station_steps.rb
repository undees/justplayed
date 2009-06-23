Given /^a list of radio stations "(.*)"$/ do
  |stations|

  app.stations = stations.split(',')
end

When /^I look up my stations$/ do
  app.lookup_stations
end

When /^I try looking up my stations$/ do
  begin
    app.lookup_stations
  rescue Timeout::Error
    # ok
  end
end

Then /^I should see the stations "([^\"]*)"$/ do
  |text|

  stations = text.split ','
  app.stations.should == stations
end

Then /^I should be invited to press Locate$/ do
  app.stations.should ==
    ['connect to network and press Locate']
end
