Given /^a fresh install$/ do
  app.restart do
    path = ['~', 'Library', 'Application Support',
            'iPhone Simulator', 'User', 'Applications',
            '**', '*.Just_Played.plist'].join('/')
    prefs = Dir[File.expand_path(path)].first

    FileUtils.rm prefs if prefs
  end
end

Given /^a test server$/ do
  app.server = test_server
end

Given /^a missing test server$/ do
  app.server = 'http://localhost:55555'
end

Given /^a city name of "(.*)"$/ do
  |city|

  app.city = city
end

Then /^the server should not be empty$/ do
  app.server.should_not be_empty
end

Then /^I should( not)? see a network warning$/ do
  |negated|

  dismiss = lambda {app.dismiss_warning}

  if negated
    dismiss.should     raise_error(JustPlayed::ExpectationFailed)
  else
    dismiss.should_not raise_error(JustPlayed::ExpectationFailed)
  end
end

Then /^I should be reminded to look up (\d+) songs? later$/ do
  |count|

  app.dismiss_warning
  app.warning_text.should =~ /#{count} of your songs/
end

Then /^I should see a help button$/ do
  app.should have_help_button
end

Then /^the app should not be downloading anything$/ do
  app.should_not be_downloading
end
