When /^I look up my stations$/ do
  app.lookup
end

Then /^I should see the stations "([^\"]*)"$/ do
  |text|

  stations = text.split ','
  app.stations.should == stations
end

Then /^I should be invited to press Refresh$/ do
  app.stations.should ==
    ['connect to network and press Refresh']
end
