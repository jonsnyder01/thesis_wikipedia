class CandidateLabel

  def initialize(tokens, string)
    @tokens = tokens
    @string = string
  end

  def to_s
    @string
  end

  def tokens
    @tokens
  end

end
