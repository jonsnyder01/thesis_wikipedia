require 'set'

class RougeMetric

  def initialize(n)
    @n = n
  end

  def call(reference, system)
    reference_tokens = token_set(reference)
    system_tokens = token_set(system)

    return 0.0 if reference_tokens.count == 0
    system_tokens.count { |system_token| reference_tokens.include?(system_token) }.to_f / reference_tokens.count
  end

  private

  def token_set(tokens)
    s = Set.new
    (0..tokens.size-@n).each do |i|
      s.add(tokens[i..i+@n-1].join(" "))
    end
    s
  end

end