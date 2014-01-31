class TopicCounts

  def initialize
    @topic_counts = []
    @sum = 0
  end

  def inc(topic)
    return unless topic
    @topic_counts[topic] = (@topic_counts[topic] || 0) + 1
    @sum += 1
  end

  def normalized_vector(topics)
    (0..topics-1).map do |topic_id|
      (@topic_counts[topic_id] || 0).to_f / @sum
    end
  end
end