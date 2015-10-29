$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'jaccard_index'

describe JaccardIndex do

  it "works" do
    JaccardIndex.call([0], [1]).should == 0
    JaccardIndex.call([0], [0]).should == 1
    JaccardIndex.call([0,1], [0]).should == 0.5
    JaccardIndex.call([0,1], [0]).should == 0.5
    JaccardIndex.call([0,1,2,3], [1]).should == 0.25
    JaccardIndex.call([2],[0,1,2,5]).should == 0.25
  end
end
