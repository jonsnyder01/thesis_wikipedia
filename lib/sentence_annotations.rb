class SentenceAnnotations
  attr_reader :raw, :tokens, :pos, :topics
  
  def initialize(raw, tokens, pos)
    @raw = raw
    @tokens = tokens
    @pos = pos
  end

  def topics=(value)
    @topics = value
  end

  def topic_counts
    counts = Hash.new(0)
    @topics.each do |value|
      counts[value] += 1 if value
    end
    counts
  end
end
