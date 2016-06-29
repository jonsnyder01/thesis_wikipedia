class CountingWordTrie

  def initialize()
    @hash = Hash.new
    @count = 0
    @terminal = false
  end

  def add_all_continuous_subsets_of_length(words, length)
    (0..words.size-1).each do |index|
      trie = self
      end_i = index + length
      end_i = words.size if end_i > words.size
      (index..end_i-1).each do |subindex|
        if !trie.hash.has_key?(words[subindex])
          new_trie = CountingWordTrie.new
          new_trie.terminal = true
          trie.hash[words[subindex]] = new_trie
        end
        trie = trie.hash[words[subindex]]
        trie.inc
      end
    end
  end

  def add_phrase(words, i=0)
    if !hash.has_key?(words[i])
      hash[words[i]] = CountingWordTrie.new
    end
    if i < words.size - 1
      hash[words[i]].add_phrase(words, i+1)
    else
      hash[words[i]].terminal = true
    end
    hash[words[i]].inc
  end

  def terminal
    @terminal
  end

  def terminal=(value)
    @terminal = value
  end

  def count
    @count
  end

  def inc
    @count += 1
  end

  def hash
    @hash
  end

  def find_phrases_in_sentence(words)
    phrases = []
    words.each_with_index do |word, i|
      trie = self
      j = i
      while j < words.size && trie.hash.has_key?(words[j])
        trie = trie.hash[words[j]]
        if trie.terminal
          phrases << words[i..j].join(" ")
        end
        j += 1
      end
    end
    phrases
  end

  def phrases
    Enumerator.new do |y|
      recursive_phrases(y, [])
    end
  end

  def recursive_phrases(y, phrase)
    hash.each do |word, trie|
      new_phrase = phrase + [word]
      if (word.terminal)
        y << new_phrase
      end
      trie.recursive_phrases(y, new_phrase)
    end
  end

end