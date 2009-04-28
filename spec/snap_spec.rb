require File.dirname(__FILE__) + '/spec_helper'

describe OSX::Snap do
  before { @snap = OSX::Snap.alloc.initWithStation('KNRK') }

  it 'describes itself with a station and time' do
    @snap.title.should == 'KNRK'
    (Time.now - Chronic.parse(@snap.subtitle)).should be < 120
  end

  it 'needs lookup' do
    @snap.needsLookup.should == 1
  end
end

describe OSX::Song do
  before { @song = OSX::Song.alloc.initWithTitle_artist('Belong', 'R.E.M.') }

  it 'describes itself with a title and artist' do
    @song.title.should == 'Belong'
    @song.subtitle.should == 'R.E.M.'
  end

  it 'needs no lookup' do
    @song.needsLookup.should == 0
  end
end
