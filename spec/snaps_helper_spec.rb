require 'cucumber'

load(File.join(File.dirname(__FILE__), '../features/support/env.rb'))

describe 'SnapsHelper', '.snaps_from_ast' do
  include SnapsHelper

  it 'converts station/time hashes' do
    ast = Cucumber::Ast::Table.new(
      [['station', 'time'],
       ['KNRK', '13:57']])
    
    expected = [{:title    => 'KNRK',
                 :subtitle => '13:57'}]

    snaps_from_ast(ast).should == expected
  end

  it 'converts artist/song hashes' do  
    ast = Cucumber::Ast::Table.new(
      [['title',   'artist'],
       ['Funtime', 'Danny Barnes']])
    
    expected = [{:title    => 'Funtime',
                 :subtitle => 'Danny Barnes'}]

    snaps_from_ast(ast).should == expected
  end
  
  it 'understands links' do
    ast = Cucumber::Ast::Table.new(
      [['station', 'time', 'link'],
       ['KNRK',    '0:00', 'yes']])
    
    expected = [{:title    => 'KNRK',
                 :subtitle => '0:00',
                 :link     => true}]

    snaps_from_ast(ast).should == expected
  end

  it 'can add creation times' do
    now = Time.now
    today_at_1357 = Time.local(now.year, now.month, now.day, 13, 57)
    today_at_1357 += 86400 if today_at_1357 < now

    ast = Cucumber::Ast::Table.new(
      [['station', 'time'],
       ['KNRK',    '13:57']])
    
    expected = [{:title      => 'KNRK',
                 :subtitle   => '13:57',
                 :created_at => today_at_1357}]

    snaps_from_ast(ast, :with_timestamp).should == expected
  end
end