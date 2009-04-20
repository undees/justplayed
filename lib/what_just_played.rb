require 'encumber'
require 'rexml/document'

class WhatJustPlayed
  def initialize
    @gui = Encumber::GUI.new
  end

  def snap(station)
    @gui.press '//UIRoundedRectButton[currentTitle="%s"]' % station
  end

  TitleTag = 1
  SubtitleTag = 2

  def snaps
    xml = @gui.dump
    doc = REXML::Document.new xml

    xpath = '//UILabel[tag="%s"]' % TitleTag
    stations = REXML::XPath.match doc, xpath
    stations.map! {|e| e.elements['text'].text}

    xpath = '//UILabel[tag="%s"]' % SubtitleTag
    times = REXML::XPath.match doc, xpath
    times.map! {|e| e.elements['text'].text}

    stations.zip(times).inject([]) do |memo, obj|
      station, time = obj
      memo << {'station' => station, 'time' => time}
    end
  end
end
