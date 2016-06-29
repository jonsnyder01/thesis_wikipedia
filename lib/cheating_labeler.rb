require 'candidate_label'

class CheatingLabeler

  def initialize(counting_phrase)
    @counting_phrase = counting_phrase
  end

  def call(topic, reference_titles)
    reference_titles.map do |title|
      tokens = find_title(@counting_phrase.trie, title, 0)
      CandidateLabel.new(tokens, tokens.join(" "))
    end
  end

  def find_title(trie, tokens, i)
    if tokens.count <= i || !trie.hash.has_key?(tokens[i])
      return []
    else
      return [tokens[i]] + find_title(trie.hash[tokens[i]], tokens, i + 1)
    end
  end
end