class IncrementalCosineSimilarity
  def initialize
    @sum_of_magnitude = 0
    @sum_of_squared_counts = 0
    @token_counts = {}
    @token_counts.default = 0
    @tokens = []
  end

  def add(token, magnitude)
    @sum_of_magnitude += magnitude
    @token_counts[token] += 1
    @sum_of_squared_counts += (@token_counts[token] * 2) - 1
    @tokens << token
  end

  def remove(token, magnitude)
    raise "Error" if @tokens.pop != token
    @sum_of_squared_counts -= (@token_counts[token] * 2) - 1
    @token_counts[token] -= 1
    @sum_of_magnitude -= magnitude
  end

  def similarity
    @sum_of_magnitude.to_f / Math.sqrt(@sum_of_squared_counts)
  end

  def tokens
    @tokens.dup
  end

  def size
    @tokens.size
  end

end