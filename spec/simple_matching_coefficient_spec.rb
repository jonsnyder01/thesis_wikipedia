$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'simple_matching_coefficient'

describe SimpleMatchingCoefficient do

  it "works" do
    SimpleMatchingCoefficient.call([0], [1], 2).should == 0
    SimpleMatchingCoefficient.call([0], [0], 1).should == 1
    SimpleMatchingCoefficient.call([0,1], [0], 3).should == 1.to_f / 3
    SimpleMatchingCoefficient.call([0,1], [0,1], 3).should == (2.to_f / 3)
    SimpleMatchingCoefficient.call([1,3,5],[2,4,5],4).should == 0.25
    SimpleMatchingCoefficient.call([],[0,1,2],100).should == 0
    SimpleMatchingCoefficient.call([],[],0).should == 1
    SimpleMatchingCoefficient.call([1],[0,1,2],4).should == 0.25
    SimpleMatchingCoefficient.call([0,1,2],[1],4).should == 0.25

  end
end
