require 'set'
require 'enumerable'

class RougeMetric

  def initialize(n)
    @n = n
  end

  def call(references, candidates)
    references_tokens = references.map { |reference| token_set(reference) }
    candidate_tokens = candidates.reduce(Set.new) { |memo, candidate| token_set(candidate, memo); memo }

    possible = references_tokens.map { |reference| reference.count }.inject(0,:+)
    return 0.0 if possible == 0
    matches = references_tokens.map {
        |reference| candidate_tokens.count { |candidate| reference.include?(candidate) }
    }.inject(0,:+)

    matches.to_f / possible
  end

  private

  def token_set(tokens, s = Set.new)
    tokens.each_ngram(@n) do |ngram|
      s.add(ngram)
    end
    s
  end

end