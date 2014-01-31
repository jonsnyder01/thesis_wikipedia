
module CosineSimilarity

  def self.call(v1, v2)
    raise ArgumentError.new("Vectors must be of equal size: #{v1.size} != #{v2.size}") unless v1.size == v2.size

    v1 = v1.map { |i| i = i.to_f; i.nan? ? 0.0 : i }
    v2 = v2.map { |i| i = i.to_f; i.nan? ? 0.0 : i }

    s1 = Math.sqrt(v1.map { |i| i * i }.inject(:+))
    s2 = Math.sqrt(v2.map { |i| i * i }.inject(:+))
    p = v1.zip(v2).map { |a1, a2| a1 * a2 }.inject(:+)
    p.to_f / (s1 * s2)
  end
end