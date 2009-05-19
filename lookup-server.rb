require 'rubygems'
require 'sinatra'

get '/:station/:time' do |station, time|
  halt 404 unless station.downcase == 'knrk' && time == '1200'
  <<HERE
<plist version="1.0">
<dict>
	<key>title</key>
	<string>Been Caught Stealing</string>
	<key>artist</key>
	<string>Jane's Addiction</string>
</dict>
</plist>
HERE
end
