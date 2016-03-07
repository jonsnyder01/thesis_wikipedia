class BigramLabeler

  def initialize(article_gateway, topic_count, options={})
    @article_gateway = article_gateway
    @size = options[:size].to_i || 5
    @topic_count = topic_count
    compute
  end

  def call(topic)
    (@topic_word_frequencies[topic.id] || {}).map do |token, tf|
      [token, tf * Math.log(@topic_count.to_f / @word_topics[token].size)]
    end.sort_by { |token, tf_idf| -tf_idf }.take(@size).map { |token, tf_idf| token }.join(" - ").split(" ")
  end

  private

  def compute
    @topic_word_frequencies = {}
    @word_topics = {}
    i = 0
    @article_gateway.each do |article|
      article.sentence_annotations.each do |sentence_annotation|
        last_topic = nil
        last_token = nil
        sentence_annotation.tokens.zip(sentence_annotation.topics).each do |token, topic|
          if last_topic == topic
            bigram = "#{last_token} #{token}"

            @topic_word_frequencies[topic] = {} if @topic_word_frequencies[topic] == nil
            @topic_word_frequencies[topic][bigram] ||= 0
            @topic_word_frequencies[topic][bigram] += 1

            @word_topics[bigram] = Set.new if @word_topics[bigram] == nil
            @word_topics[bigram] << topic
          end
          last_topic = topic
          last_token = token
        end
      end
      puts i if i % 1000 == 0
      i+=1
    end
  end
end