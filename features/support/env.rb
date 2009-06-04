$: << File.join(File.dirname(__FILE__), '/../../lib')

require 'just_played'
require 'fileutils'
require 'chronic'
require 'spec/expectations'

module SnapsHelper
  def app
    @app ||= JustPlayed.new
  end
end

World(SnapsHelper)

Before do
  app.reset
end
