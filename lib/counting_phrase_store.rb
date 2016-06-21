require 'counting_phrase'
require 'counting_word_trie'

class CountingPhraseStore

  def initialize(marshal_helper, location)
    @marshal_helper = marshal_helper
    @location = location
  end

  def create_n_gram_phrases(article_gateway, depth)
    trie = CountingWordTrie.new
    article_gateway.each do |article|
      article.sentence_annotations.each do |sentence_annotation|
        trie.add_all_continuous_subsets_of_length(sentence_annotation.tokens, depth)
      end
    end

    @counting_phrase = CountingPhrase.new(trie, depth)
  end

  def create_noun_phrases(article_gateway)
    trie = CountingWordTrie.new
    longest_phrase = 0
    article_gateway.each do |article|
      article.phrases.each do |phrase|
        trie.add_phrase(phrase.tokens)
        if phrase.tokens.size > longest_phrase
          longest_phrase = phrase.tokens.size
        end
      end
    end

    @counting_phrase = CountingPhrase.new(trie, longest_phrase)
  end

  def counting_phrase
    return @counting_phrase if @counting_phrase
    load
  end

  def flush
    @marshal_helper.dump(@counting_phrase, @location)
  end

  private

  def load
    @counting_phrase = @marshal_helper.load(@location)
  end
end