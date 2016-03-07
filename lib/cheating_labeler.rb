require 'word_frequency'
require 'word_trie'

class CheatingLabeler

  def initialize(category_gateway, article_gateway, window_size)
    @category_gateway = category_gateway
    @article_gateway = article_gateway
    @window_size = window_size
  end

  def compute_context_models
    @phrase_context_models = Hash.new {|hash, key| hash[key] = WordFrequency.new }
    trie = WordTrie.new
    @category_gateway.each do |category|
      trie.add(category.annotation.tokens)
    end
    @article_gateway.each do |article|
      article_tokens = []
      article.sentence_annotations.each do |sentence|
        article_tokens += sentence.tokens
      end
      trie.find_with_window(article_tokens, @window_size).each do |phrase, context|
        word_freq = @phrase_context_models[phrase.join(' ')]
        article_tokens.each do |word|
          word_freq.add(word)
        end
      end
    end
  end

  def compute_topic_models
    @topic_models = Hash.new {|hash, key| hash[key] = WordFrequency.new }
    @article_gateway.each do |article|
      article.sentence_annotations.each do |sentence_annotation|
        sentence_annotation.tokens.zip(sentence_annotation.topics).each do |token, topic|
          @topic_models[topic].add(token)
        end
      end
    end
  end

  def call(topic)
    puts topic.mallet_data.to_s
    if @phrase_context_models.nil?
      compute_context_models
      compute_topic_models
    end
    sorted_scores = @phrase_context_models.map do |phrase, model|
      [phrase, @topic_models[topic.id].cross_entropy(model)]
    end.sort_by { |phrase, ce| ce }
    sorted_scores.first(5).map { |phrase, ce| "(#{sprintf('$.2f',ce)}) #{phrase})" }.join(' - ').split(' ')
  end
end