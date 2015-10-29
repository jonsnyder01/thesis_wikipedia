
module SimpleMatchingCoefficient
  def self.call(v1, v2, size)
    return 1 if size == 0 

    intersection = 0
    i1 = 0
    i2 = 0
    while i1 < v1.size && i2 < v2.size
      x1 = v1[i1]
      x2 = v2[i2]
      if x1 == x2
        i1 += 1
        i2 += 1
        intersection += 1
      elsif x1 > x2
        i2 += 1
      else
        i1 += 1
      end
    end

    return intersection.to_f / size

=begin
    i = 0
    matches = 0
    while i < v1.size
      matches += 1 if (v1[i] > 0) == (v2[i] > 0)
      i += 1
    end

    return matches.to_f/ i
=end
  end
end
