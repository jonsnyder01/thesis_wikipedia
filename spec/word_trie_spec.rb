$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'word_trie'

describe WordTrie do

  subject { WordTrie.new }

  let(:counts) { Hash.new { 0 } }

  it 'handles no words added' do
    # subject.label(['hello','world']).to_a.should == [false, false]
    subject.count(['hello','world'], counts)
    counts.should == {}
  end

  it 'handles one word' do
    subject.add(['is'])
    # subject.label(['the','answer','is','42']).should == [false, false, true, false]
    subject.count(['the','answer','is','42'], counts)
    counts.should == {'is' => 1}
  end

  it 'handle multi-word queries' do
    subject.add(['brown'])
    subject.add(['brown','fox'])
    # subject.label(['the','quick','brown','fox','jumps']).should == [false,false,true,true,false]
    subject.count(['the','quick','brown','fox','jumps'], counts)
    counts.should == {'brown' => 1, 'brown fox' => 1}
  end

  it 'gets context' do
    subject.get_context(%w(1), 3, 0, 0).should == []
    subject.get_context(%w(1 2 3 4 5 6 7 8 9 10), 3, 4, 5).should == %w(2 3 4 7 8 9)
    subject.get_context(%w(1 2 3 4 5 6 7 8 9 10), 3, 1, 3).should == %w(1 5 6 7)
    subject.get_context(%w(1 2 3 4 5 6 7 8 9 10), 3, 0, 2).should == %w(4 5 6)
    subject.get_context(%w(1 2 3 4 5 6 7 8 9 10), 10, 7, 7).should == %w(1 2 3 4 5 6 7 9 10)
    subject.get_context(%w(1 2 3 4 5 6 7 8 9 10), 2, 8, 9).should == %w(7 8)
    subject.get_context(%w(1 2 3 4 5), 0, 2, 2).should == []
  end
end