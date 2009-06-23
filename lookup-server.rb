require 'rubygems'
require 'sinatra'
require 'time'

get '/stations/:location' do |location|
  <<HERE
<plist version="1.0">
<dict>
	<key>KNRK</key>
	<string>http://yes.com/KNRK</string>
	<key>KOPB</key>
	<string>http://yes.com/KOPB</string>
</dict>
</plist>
HERE
end

get '/:station/:time' do |station, time|
  sleep 1
  local_clock = Time.parse(time).strftime('%H%M')
  puts local_clock
  halt 404 unless station.downcase == 'knrk' && local_clock == '1200'
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
