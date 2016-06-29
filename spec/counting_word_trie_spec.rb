$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'counting_word_trie'

describe CountingWordTrie do
  subject { CountingWordTrie.new }

  it 'adds all the continuous subsets' do
    subject.add_all_continuous_subsets_of_length(%w(i like cats), 3)
    subject.terminal.should == false
    subject.hash['i'].terminal.should == true
    subject.hash['i'].hash['like'].terminal.should == true
    subject.hash['i'].hash['like'].hash['cats'].terminal.should == true
    subject.hash['like'].terminal.should == true
    subject.hash['like'].hash['cats'].terminal.should == true
    subject.hash['cats'].terminal.should == true

    subject.hash['i'].count.should == 1
    subject.hash['i'].hash['like'].count.should == 1
    subject.hash['i'].hash['like'].hash['cats'].count.should == 1
    subject.hash['like'].count.should == 1
    subject.hash['like'].hash['cats'].count.should == 1
    subject.hash['cats'].count.should == 1
    subject.hash['foo'].should == nil
  end

  it 'handles multiples' do
    subject.add_all_continuous_subsets_of_length(%w(i like cats), 3)
    subject.add_all_continuous_subsets_of_length(%w(i like dogs), 3)
    subject.hash['i'].count.should == 2
    subject.hash['i'].hash['like'].count.should == 2
    subject.hash['i'].hash['like'].hash['cats'].count.should == 1
    subject.hash['i'].hash['like'].hash['dogs'].count.should == 1
    subject.hash['like'].count.should == 2
    subject.hash['like'].hash['cats'].count.should == 1
    subject.hash['like'].hash['dogs'].count.should == 1
    subject.hash['cats'].count.should == 1
    subject.hash['dogs'].count.should == 1

    subject.hash.keys.should == %w(i like cats dogs)
  end

  it 'uses the length' do
    subject.add_all_continuous_subsets_of_length(%w(a b c d e), 3)
    subject.hash['a'].count.should == 1
    subject.hash['b'].count.should == 1
    subject.hash['c'].count.should == 1
    subject.hash['d'].count.should == 1
    subject.hash['e'].count.should == 1
    subject.hash['a'].hash['b'].count.should == 1
    subject.hash['b'].hash['c'].count.should == 1
    subject.hash['c'].hash['d'].count.should == 1
    subject.hash['d'].hash['e'].count.should == 1
    subject.hash['a'].hash['b'].hash['c'].count.should == 1
    subject.hash['b'].hash['c'].hash['d'].count.should == 1
    subject.hash['c'].hash['d'].hash['e'].count.should == 1
  end

  it 'adds phrases' do
    subject.add_phrase(%w(i like cats))
    subject.add_phrase(%w(i like dogs))
    subject.hash['i'].count.should == 2
    subject.hash['i'].hash['like'].count.should == 2
    subject.hash['i'].hash['like'].hash['cats'].count.should == 1
    subject.hash['i'].hash['like'].hash['dogs'].count.should == 1
    subject.hash['like'].should == nil

    subject.terminal.should == false
    subject.hash['i'].terminal.should == false
    subject.hash['i'].hash['like'].terminal.should == false
    subject.hash['i'].hash['like'].hash['cats'].terminal.should == true
    subject.hash['i'].hash['like'].hash['dogs'].terminal.should == true
  end

  it 'can find the phrases in a sentence' do
    subject.add_phrase(%w(i like))
    subject.add_phrase(%w(like cats))
    subject.add_phrase(%w(do))

    subject.find_phrases_in_sentence(%w(i like cats yes i do)).should == ["i like","like cats", "do"]
    subject.find_phrases_in_sentence(%w(a b c d e)).should == []
    subject.find_phrases_in_sentence(%w(do)).should == ["do"]
  end
end
