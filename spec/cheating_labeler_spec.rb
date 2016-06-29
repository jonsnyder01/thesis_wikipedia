$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'cheating_labeler'
require 'counting_phrase'
require 'counting_word_trie'

describe CheatingLabeler do

  let(:trie) {
    it = CountingWordTrie.new
    it.add_all_continuous_subsets_of_length(%w(i like cats), 3)
    it
  }
  subject { CheatingLabeler.new(CountingPhrase.new(trie, nil)) }

  it "returns empty array when it is not present" do
    subject.call(nil, [%w(foo)]).map(&:to_s).should == [""]
  end

  it "finds single word titles" do
    subject.call(nil, [%w(i like cats)]).map(&:to_s).should == ["i like cats"]
  end

end
