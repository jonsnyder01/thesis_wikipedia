require 'word_frequency'
require 'word_trie'

class CheatingTfidfLabeler

  def initialize(category_gateway, article_gateway, topic_count)
    @category_gateway = category_gateway
    @article_gateway = article_gateway
    @topic_count = topic_count
  end

  def compute_models
    trie = WordTrie.new
    @category_gateway.each do |category|
      trie.add(category.annotation.tokens)
    end
    @candidate_counts = Hash.new
    @candidate_counts.default = 0
    @article_gateway.each do |article|
      article.sentence_annotations.each do |sentence|
        trie.count(sentence.tokens, @candidate_counts)
      end
    end

    @topic_word_frequencies = Hash.new { |hash, key| hash[key] = WordFrequency.new }
    @topic_frequencies = WordFrequency.new
    @article_gateway.each do |article|
      article.sentence_annotations.each do |sentence_annotation|
        sentence_annotation.tokens.zip(sentence_annotation.topics).each do |token, topic|
          if (@topic_word_frequencies[topic].freq(token) == 0)
            @topic_frequencies.add(token)
          end
          @topic_word_frequencies[topic].add(token)
        end
      end
    end
  end

  def call(topic)
    if @candidate_counts.nil?
      compute_models
    end

    @candidate_counts.keys.map do |phrase|
      [phrase, phrase.split(' ').map { |token| tf_idf(topic.id, token) }.inject(0, :+) ]
    end.sort_by { |phrase, tf_idf| -tf_idf }.take(5).map { |phrase, tf_idf| phrase }.join(' - ').split(' ')
  end

  def tf_idf(topic_id, token)
    @topic_word_frequencies[topic_id].freq(token) * Math.log(@topic_count.to_f / @topic_frequencies.freq(token))
  end

end