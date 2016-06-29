require 'word_frequency'

class TopicVectorGenerator

  def initialize(article_gateway)
    @article_gateway = article_gateway
  end

  def zero_order_topic_vectors
    topic_vectors = {}
    word_freq = WordFrequency.new
    all_token_topic_pairs.each do |token, topic|
      word_freq.add(token)
      topic_vectors[topic] ||= Hash.new(0)
      topic_vectors[topic][token] += 1
    end

    topic_vectors.each do |topic, vectors|
      vectors.each do |word, freq|
        vectors[word] = freq.to_f / word_freq.freq(word)
      end
    end

    topic_vectors
  end

  def frequency_topic_vectors
    topic_vectors = {}
    all_token_topic_pairs.each do |token, topic|
      topic_vectors[topic] ||= Hash.new(0)
      topic_vectors[topic][token] += 1
    end
    topic_vectors
  end

  def tf_idf_topic_vectors
    topic_vectors = {}
    word_topics = {}
    all_token_topic_pairs.each do |token, topic|
      topic_vectors[topic] ||= {}
      topic_vectors[topic][token] ||= 0
      topic_vectors[topic][token] += 1

      word_topics[token] ||= Set.new
      word_topics[token] << topic
    end
    topic_count = word_topics.keys.size
    topic_vectors.each do |topic, topic_vector|
      topic_vector.each do |token, count|
        topic_vector[token] = count * Math.log(topic_count / word_topics[token].size)
      end
    end
    topic_vectors
  end

  private

  def all_token_topic_pairs
    i = 0
    Enumerator.new do |y|
      @article_gateway.each do |article|
        article.sentence_annotations.each do |sentence_annotation|
          sentence_annotation.tokens.zip(sentence_annotation.topics).each do |token, topic|
            next if topic.nil?
            y << [token, topic]
          end
        end
        puts i if i % 1000 == 0
        i += 1
      end
    end
  end

end