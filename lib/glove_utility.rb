class GloveUtility

  def initialize(io)
    @io = io
  end

  def find_words(words)
    words_left_to_find = words.count
    @io.rewind
    @io.each_line do |line|
      first_space = line.index(" ")
      word = line[0..first_space-1]
      if (words.has_key?(word))
        vector = line[first_space+1..-1].split(" ").map(&:to_f)
        yield [word, vector]
        words_left_to_find -= 1
        if words_left_to_find == 0
          break
        end
      end
    end
  end

  def nearest_neighbors(vector, count)
    nearest_neighbors = []

    @io.rewind
    @io.each_line do |line|
      first_space = line.index(" ")
      word = line[0..first_space-1]
      other_vector = line[first_space+1..-1].split(" ").map(&:to_f)
      distance = vector.zip(other_vector).map { |a, b| (b - a)**2 }.inject(0,:+)
      insertion_point = nearest_neighbors.rindex { |d, w, v| d < distance }
      insertion_point = insertion_point == nil ? 0 : insertion_point + 1
      if insertion_point < count
        nearest_neighbors.insert(insertion_point, [distance, word, other_vector])
        if nearest_neighbors.count > count
          nearest_neighbors.pop
        end
      end
    end
    nearest_neighbors
  end
end