$: << File.join(File.dirname(__FILE__), '/../../lib')

require 'what_just_played'
require 'chronic'
require 'spec/expectations'

module SnapsHelper
  def app
    @app ||= WhatJustPlayed.new
  end
end

World(SnapsHelper)

Before do
  app.reset
end
