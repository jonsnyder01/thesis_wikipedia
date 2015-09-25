class SimilarityMatrix

  class Vector
    include Enumerable

    def initialize(id, key_counts)
      @id = id
      @key_counts = key_counts
    end

    def each(&block)
      normalized_key_counts.each(&block)
    end

    def [](key)
      normalized_key_counts[key]
    end

    def id
      @id
    end

    private

    def normalized_key_counts
      @normalized_key_counts ||= begin
        length = Math.sqrt(@key_counts.values.reduce(0) { |sum,value| sum + value*value })
        normalized = {}
        @key_counts.each { |key,value| normalized[key] = value.to_f / length }
        normalized
      end
    end
  end

  def initialize(vectors)
    @vectors = vectors
  end

  def calculate(output_file, from, to)
    @vectors[from..to].each_with_index do |vector, i|
      row = Array.new(@vectors.size,0.0)
      vector.each do |key, value|
        vectors_with_key(key).each do |other_vector|
          row[other_vector.id] += value * other_vector[key]
        end
      end
      output_file.puts row.map { |v| sprintf("%.3f",v) }.join(" ")
      puts "#{from}..#{to}: #{i}" if i % 100 == 0
    end
  end

  def vectors_with_key(key)
    @index ||= begin
      index = Hash.new { [] }
      @vectors.each do |vector|
        vector.each do |key, count|
          index[key] = index[key] << vector
        end
      end
      index
    end
    @index[key]
  end


end