require 'word_frequency'

class LabelContextModel

  def initialize()
    @label_context_word_frequencies = {}
    @word_frequency = WordFrequency.new
    @label_frequency = WordFrequency.new
  end

  def add_sentence_with_labels(sentence, labels)
    sentence.each { |word| @word_frequency.add(word) }

    labels.each do |label|
      @label_frequency.add(label)
      if !@label_context_word_frequencies.has_key?(label)
        @label_context_word_frequencies[label] = WordFrequency.new
      end
      label_context_word_frequency = @label_context_word_frequencies[label]
      sentence.each { |word| label_context_word_frequency.add(word) }
    end
  end

  def compute_label_distributions()
    puts "compute_label_distributions"
    label_distributions = {}
    word_lp = {}
    word_count = @word_frequency.count
    vocab_size = @word_frequency.words.size
    @word_frequency.words.each_with_index do |word, i|
      word_lp[word] = Math.log(@word_frequency.freq(word).to_f / word_count)
      puts i if i % 1000 == 0
    end

    label_context_count = @label_context_word_frequencies.map { |label, freq| freq.count }.inject(0,&:+)
    label_count = @label_frequency.count
    label_size = @label_frequency.words.size

    @label_frequency.words.each_with_index do |label, i|
      label_lp = Math.log(@label_frequency.freq(label).to_f / label_count)

      puts "#{i}/#{label_size} #{label}"
      label_distribution = {}
      @label_context_word_frequencies[label].words.each do |word|
        word_label_lp = Math.log(
            @label_context_word_frequencies[label].freq(word).to_f / label_context_count)
        label_distribution[word] = word_label_lp - word_lp[word] - label_lp
      end
      print label_distribution.map {|word, score| [word, score]}.sort_by { |word, score| -1 * score }.take(10)
      puts ""
      label_distributions[label] = label_distribution
    end

    label_distributions
  end

end