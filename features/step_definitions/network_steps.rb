Given /^a fresh install$/ do
  app.restart do
    path = ['~', 'Library', 'Application Support',
            'iPhone Simulator', 'User', 'Applications',
            '**', '*.Just_Played.plist'].join('/')
    prefs = Dir[File.expand_path(path)].first

    FileUtils.rm prefs if prefs
  end
end

Then /^the server should not be empty$/ do
  app.server.should_not be_empty
end

Then /^I should see a network warning$/ do
  app.dismiss_warning
end
