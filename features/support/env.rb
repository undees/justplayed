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
      h2 = h.dup
      h2[:link] = (h2[:link] == 'yes') if h2.keys.include?(:link)
      h2[:created_at] = Chronic.parse(h2[:subtitle]) if with_timestamp
      h2
    end
  end
end

World(SnapsHelper)

Before do
  app.reset
end
