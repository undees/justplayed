require File.dirname(__FILE__) + '/spec_helper'

describe OSX::Snap do
  it 'has a dictionary representation' do
    snap = OSX::Snap.alloc.initWithStation('KNRK')
    snap.propertyList.objectForKey('title').should == 'KNRK'
  end

  it 'can read a dictionary representation' do
    plist = OSX::NSDictionary.alloc.initWithObjectsAndKeys \
      'Canon in D', 'title',
      'Johann Pachelbel', 'subtitle', nil

    snap = OSX::Snap.alloc.initWithPropertyList(plist)
    snap.title.should == 'Canon in D'
  end
end

describe OSX::Snap, ' after creation' do
  before { @snap = OSX::Snap.alloc.initWithStation('KNRK') }

  it 'describes itself with a station and time' do
    @snap.title.should == 'KNRK'
    (Time.now - Chronic.parse(@snap.subtitle)).should be < 120
  end

  it 'needs lookup' do
    @snap.needsLookup.should == 1
  end
end

describe OSX::Snap, ' after lookup' do
  before { @snap = OSX::Snap.alloc.initWithTitle_artist('Belong', 'R.E.M.') }

  it 'describes itself with a title and artist' do
    @snap.title.should == 'Belong'
    @snap.subtitle.should == 'R.E.M.'
  end

  it 'needs no lookup' do
    @snap.needsLookup.should == 0
  end
end
