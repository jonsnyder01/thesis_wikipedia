class SentenceAnnotations
  attr_reader :raw, :words, :tokens, :token_mapping, :topics
  
  def initialize(raw, words, tokens, token_mapping)
    @raw = raw
    @words = words
    @tokens = tokens
    @token_mapping = token_mapping
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
