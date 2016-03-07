$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'critical_binomial'

describe CriticalBinomial do

  it "calculates combinations correctly" do
    CriticalBinomial.combinations(1,1).should == 1
    CriticalBinomial.combinations(3,2).should == 3
    CriticalBinomial.combinations(4,2).should == 6
    CriticalBinomial.combinations(5,3).should == 10
    CriticalBinomial.combinations(10, 5).should == 252
  end

  it "calculates the critical value correctly" do
    CriticalBinomial.critical_binomial(100, 0.05, 0.95).should == 9
    CriticalBinomial.critical_binomial(100, 0.25, 0.95).should == 32
  end
end

