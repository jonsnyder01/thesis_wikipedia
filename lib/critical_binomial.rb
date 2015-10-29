class CriticalBinomial

  def self.critical_binomial(n,p)
    prob = 0
    x = 0
    combinations_stream(n) do |combinations|
      prob += p**x * (1-p)**(n-x) * combinations
      if prob >= 0.95
        break
      end
      x += 1
    end
    x
  end

  def self.combinations(n, x)
    combinations_stream(n) do |combinations|
      if x == 0
        return combinations
      end
      x -= 1
    end
  end

  def self.combinations_stream(n)
    combinations = 1
    n.times do |x|
      yield combinations
      combinations *= (n - x).to_f / (x + 1)
    end
  end

end
