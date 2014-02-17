module Enumerable

  def each_ngram(size)
    return to_enum(:each_ngram, size) unless block_given?

    gram = []
    self.each do |i|
      gram << i
      if gram.size > size
        gram.shift
      end
      if gram.size == size
        yield gram.dup
      end
    end
  end
end