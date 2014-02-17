$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'sparse_vector'

describe SparseVector do
  subject { SparseVector.new }

  it "merges sets" do
    subject.merge(Set.new([0,1,2]))
    subject.to_a.should == [[0,1],[1,1],[2,1]]
  end

  it "merges other sparse vectors" do
    other = SparseVector.new
    other.merge(Set.new([2,4]))
    subject.merge(other)
    subject.to_a.should == [[2,2],[4,2]]
  end

  it "handles other sparse vectors and sets" do
    other = SparseVector.new
    other.merge(Set.new([42,6]))
    subject.merge(Set.new([10]))
    subject.merge(other)
    subject.to_a.should == [[10,1],[42,2],[6,2]]
  end
end