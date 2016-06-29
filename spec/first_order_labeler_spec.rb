$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'first_order_labeler'
require 'counting_word_trie'

describe FirstOrderLabeler do
  it 'works' do
    trie = CountingWordTrie.new
    trie.add_phrase(%w(red dogs))
    trie.add_phrase(%w(yellow cats))
    trie.add_phrase(%w(cool))
    article_gateway = [
        double(sentence_annotations: [
            double(tokens: %w(i like cool big red dogs)),
            double(tokens: %w(i like small red dogs)),
            double(tokens: %w(big yellow cats are cool))
        ])
    ]
    topic_vectors = {
        1 => {"i" => 1, "like" => 2, "big" => 3, "red" => 4, "dogs" => 5,
              "small" => 6, "yellow" => 7, "cats" => 8, "are" => 9, "cool" => 10},
        2 => {"i" => 10, "like" => 9, "big" => 8, "red" => 7, "dogs" => 6,
              "small" => 5, "yellow" => 4, "cats" => 3, "are" => 2, "cool" => 1}
    }
    labeler = FirstOrderLabeler.new(article_gateway, double(trie: trie), topic_vectors, 3)
    labeler.call(double(id: 1)).map(&:to_s).should == ["   26.9614 yellow cats", "    2.4271 cool", "  -10.4550 red dogs"]
    labeler.call(double(id: 2)).map(&:to_s).should == ["    2.7013 yellow cats", "   -3.0388 red dogs", "   -9.5919 cool"]

  end
end
