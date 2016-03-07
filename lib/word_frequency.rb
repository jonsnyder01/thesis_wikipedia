class WordFrequency

  def initialize

    @freq = Hash.new
    @freq.default = 0
    @count = 0
    @llsp = {}
  end

  def add( word)
    @count += 1
    @freq[word] += 1
  end

  def freq( word)
    if !@freq.has_key?( word)
      0
    else
      @freq[word]
    end
  end

  def words
    @freq.keys
  end

  def top_n_words( n)
    @freq.sort_by { |word, freq| -1 * freq }.take(n)
  end

  def words_occurring_more_than_n_times( n)
    words = []
    @freq.each do |word, freq|
      if freq > n
        words << [word, freq]
      end
    end
    words
  end

  def words_occurring_once
    words = []
    @freq.each do |word, freq|
      if freq == 1
        words << [word, freq]
      end
    end
    words
  end

  def log_laplace_smoothing_prob( word)
    @llsp[word] ||= Math.log( (freq( word) + 1).to_f / (@count + @freq.keys.count))
  end

  def length
    @l ||= Math.sqrt( (@freq.values.reduce(0) { |sum,freq| sum + (freq*freq) }).to_f)
  end

  def cosine_similarity(other)
    sum = 0
    @freq.each { |word,freq| sum += freq * other.freq(word) }
    sum / (length * other.length)
  end

  def cross_entropy(other)
    sum = 0
    @freq.each do |word,freq|
      f = freq(word)
      sum -= (f.to_f / @count) * other.log_laplace_smoothing_prob(word) if f != 0
    end
    sum
  end

  def keep_only_top(n)
    @freq = Hash[@freq.sort_by { |word, freq| -1 * freq}.take(n)]
    @freq.default = 0
    @count = @freq.values.sum
    @llsp = {}
  end

end