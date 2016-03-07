
module JaccardIndex
  def self.call(v1, v2)
    intersection = 0
    union = 0
    i1 = 0
    i2 = 0
    while i1 < v1.size && i2 < v2.size
      x1 = v1[i1]
      x2 = v2[i2]
      if x1 == x2
        # true positive
        i1 += 1
        i2 += 1
        intersection += 1
        union += 1
      elsif x1 > x2
        #
        i2 += 1
        union += 1
      else
        i1 += 1
        union += 1
      end
    end

    if i1 == v1.size
      union += v2.size - i2
    else 
      union += v1.size - i1
    end

=begin
    i = 0
    intersection = 0
    union = 0
    while i < v1.size
      x = v1[i] > 0
      y = v2[i] > 0
      intersection +=1 if x && y
      union += 1 if x || y
      i += 1
    end
=end
    return 1 if union == 0
    return intersection.to_f / union
  end
end
