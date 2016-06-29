require 'word_frequency'
require 'top_n_filter'

class SignificantLabels

  def initialize(counting_phrase, article_gateway)
    @counting_phrase = counting_phrase

    @word_freq = WordFrequency.new
    @sentences = 0
    article_gateway.each do |article|
      article.sentence_annotations.each do |sentence_annotation|
        @sentences += 1
        sentence_annotation.tokens.each do |word|
          @word_freq.add(word)
        end
      end
    end
  end

  def call(size)
    top = TopNFilter.new(size)
    recursive_processor(@counting_phrase.trie, [], 0, top)

    top.top
  end

  def recursive_processor(trie, label, prob, top)
    trie.hash.each do |word, sub_trie|
      label.push(word)

      new_prob = prob + (1.to_f / @word_freq.freq(word))
      #new_prob = prob * (@word_freq.freq(word).to_f / @word_freq.count)
      if sub_trie.terminal && sub_trie.count >= 3
        #e = new_expected * (@word_freq.count - (label.size - 1) * @sentences)
        #label_prob = sub_trie.count.to_f / (@word_freq.count - (label.size - 1) * @sentences)

        #pmi = label_prob / new_prob
        pmi = new_prob * sub_trie.count / label.size

        top.add(sub_trie.count) { label.dup }
      end
      if label.size < 2
        recursive_processor(sub_trie, label, new_prob, top)
      end

      label.pop()
    end
  end

end