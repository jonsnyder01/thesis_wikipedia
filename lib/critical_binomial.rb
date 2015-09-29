class CriticalBinomial

  def self.critical_binomial(n, p)
    prob = 0
    x = 0
    while prob < 0.95
      prob += p**x * (1-p)**(n-x) * combinations(n,x)
      x += 1
    end
    x - 1
  end

  def self.combinations(n, x)
    if x == 0
      return 1
    end
    return self.combinations(n,x-1) * (n - x + 1).to_f / x
  end


end
