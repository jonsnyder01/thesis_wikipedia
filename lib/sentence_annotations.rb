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
end
