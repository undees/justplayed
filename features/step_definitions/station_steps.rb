When /^I look up my stations$/ do
  app.lookup
end

When /^I try looking up my stations$/ do
  begin
    app.lookup
  rescue Timeout::Error
    # ok
  end
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
