require 'encumber'
require 'rexml/document'

class WhatJustPlayed
  def initialize
    @gui = Encumber::GUI.new
    @gui.command 'resetApp'
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
    titles = REXML::XPath.match doc, xpath
    titles.map! {|e| e.elements['text'].text}

    xpath = '//UILabel[tag="%s"]' % SubtitleTag
    subtitles = REXML::XPath.match doc, xpath
    subtitles.map! {|e| e.elements['text'].text}

    titles.zip(subtitles).inject([]) do |memo, obj|
      title, subtitle = obj
      memo << {:title => title, :subtitle => subtitle}
    end
  end

  def snaps=(list)
    @gui.command 'setTestData', :raw, 'snaps', WhatJustPlayed.snap_plist(list)
  end

  def server=(url)
    @gui.command 'setTestData', 'lookupPattern', url
  end

  def time=(time)
    @gui.command 'setTestData', 'testTime', time
  end

  def lookup
    @gui.press '//UIToolbarButton'
  end

  def WhatJustPlayed.snap_plist(snaps)
    Tagz.tagz do
      array_ do
        snaps.each do |snap|
          dict_ do
            key_ 'title'
            string_ snap[:title]
            key_ 'subtitle'
            string_ snap[:subtitle]
            key_ 'needsLookup'
            snap[:complete] ? key_('false') : key_('true')
          end
        end
      end
    end
  end
end
