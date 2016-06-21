class ChunkedPhrase
  attr_reader :words, :tokens, :token_mapping

  def initialize(words, tokens, token_mapping)
    @words = words
    @tokens = tokens
    @token_mapping = token_mapping
  end
end