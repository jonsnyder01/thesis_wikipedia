class WordTrie

  def initialize()
    @hash = Hash.new { |hash, key| hash[key] = WordTrie.new }
    @terminal = false
  end

  def add(words)
    if words.empty?
      @terminal = true
    else
      @hash[words.first].add(words.drop(1))
    end
  end

  def contains?(word)
    if words.empty?
      @terminal
    elsif @hash.has_key?(words.first)
      @hash[words.first].contains(words.drop(1))
    else
      false
    end
  end

  def terminal?
    @terminal
  end

  def hash
    @hash
  end

  def label(words)
    tries = []
    Enumerator.new do |labels|
      words.each do |word|
        tries.map { |trie| }
        if @hash.has_key?(word)
          tries << @hash[word]
        end
      end
    end
  end

  def count(words, counts)
    trie_phrase_pairs = []
    words.each do |word|
      trie_phrase_pairs = trie_phrase_pairs.map do |trie, phrase|
        if trie.hash.has_key?(word)
          [trie.hash[word], phrase + " " + word]
        else
          nil
        end
      end.compact
      if @hash.has_key?(word)
        trie_phrase_pairs << [@hash[word], word]
      end
      trie_phrase_pairs.each do |trie, phrase|
        if trie.terminal?
          counts[phrase] += 1
        end
      end
    end
  end

  def find_with_window(words, window_size)
    Enumerator.new do |y|
      trie_phrase_pairs = []
      words.each_with_index do |word, word_i|
        trie_phrase_pairs = trie_phrase_pairs.map do |trie, phrase|
          if trie.hash.has_key?(word)
            [trie.hash[word], phrase + [word]]
          else
            nil
          end
        end.compact
        if @hash.has_key?(word)
          trie_phrase_pairs << [@hash[word], [word]]
        end
        trie_phrase_pairs.each do |trie, phrase|
          if trie.terminal?
            y << [phrase, get_context(words, window_size, word_i - phrase.size, word_i)]
          end
        end
      end
    end
  end

  def get_context(words, window_size, center_start, center_end)
    context = []
    start_index = max(center_start - window_size, 0)
    end_index = center_start - 1
    if end_index >= start_index
      context += words[start_index..end_index]
    end
    start_index = center_end + 1
    end_index = min(center_end + window_size, words.length - 1)
    if end_index >= start_index
      context += words[start_index..end_index]
    end
    return context
  end

  def max(a, b)
    a > b ? a : b
  end

  def min(a, b)
    a > b ? b : a
  end
end