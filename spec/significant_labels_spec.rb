$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'significant_labels'
require 'counting_word_trie'

describe SignificantLabels do


  it 'works' do
    counting_phrase = CountingWordTrie.new
    counting_phrase.add_phrase(%w(red fish))
    counting_phrase.add_phrase(%w(blue fish))
    counting_phrase.add_phrase(%w(blue fish))

    article_gateway = [
        double(sentence_annotations: [
                   double(tokens: %w(one fish two fish red fish blue fish)),
                   double(tokens: %w(black fish blue fish old fish new fish)),
                   double(tokens: %w(this blue one has a little star this one has a little car))
               ])
    ]
    subject = SignificantLabels.new(double(trie: counting_phrase), article_gateway)
    subject.call(2).map { |score, label| [score.round(2), label] }.should ==
        [[4.04, ["red", "fish"]], [2.7, ["blue", "fish"]]]
  end

end