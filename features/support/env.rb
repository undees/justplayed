$: << File.join(File.dirname(__FILE__), '/../../lib')

require 'just_played'
require 'fileutils'
require 'chronic'
require 'spec/expectations'

module SnapsHelper
  def app
    @app ||= JustPlayed.new 'localhost'
  end

  def test_server
    'http://localhost:4567'
  end
  
  def snaps_from_table(t, with_timestamp = nil)
    [['station',  :title],
     ['time',     :subtitle],
     ['title',    :title],
     ['artist',   :subtitle],
     ['subtitle', :subtitle],
     ['link',     :link]].each do |before, after|
       t = t.map_headers({before => after}) if t.headers.include?(before)
    end
    
    t.hashes.map do |h|
      h[:link] = (h[:link] == 'yes') if h.keys.include?(:link)
      h[:created_at] = Chronic.parse(h[:subtitle]) if with_timestamp
      h
    end
  end
end

World(SnapsHelper)

Before do
  app.reset
end
