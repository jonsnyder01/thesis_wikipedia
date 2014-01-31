$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'cosine_similarity'

describe CosineSimilarity do

  it "works with orthogonal vectors" do
    CosineSimilarity.call([1, 0], [0, 1]).should == 0.0
  end

  it "works with matching vectors" do
    CosineSimilarity.call([15, 0], [0.5, 0]).should == 1.0
  end

  it "works with arbitrary vectors" do
    CosineSimilarity.call([1,2], [3,4]).should == 11.to_f / (Math.sqrt(5) * 5)
  end

  it "throws an error with mismatched sized arrays" do
    expect { CosineSimilarity.call([1, 0, 2], [3, 4]) }.to raise_error(ArgumentError)
  end

  it "works with NAN" do
    CosineSimilarity.call([1,0], [Float::NAN, 1]).should == 0.0
  end
end
