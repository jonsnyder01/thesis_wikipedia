require 'critical_binomial'

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

  def statistically_significant_vector(topics)
    critical_value = CriticalBinomial.critical_binomial(@sum, 1.to_f / topics)
    (0..topics-1).to_a.map do |topic_id|
      (@topic_counts[topic_id] || 0) >= critical_value ? 1 : 0;
    end
  end
end
