$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )
require 'sparse_vector'
require 'in_memory_marshal_helper'
require 'object_store'

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

  it "marshals correctly" do

    marshal_helper = InMemoryMarshalHelper.new
    object_store = ObjectStore.new(marshal_helper, "foo") { SparseVector.new }
    sv = object_store[42]
    object_store[42] = sv
    sv.merge(Set.new([0,1,2]))
    object_store[42].to_a.should == [[0,1],[1,1],[2,1]]
    object_store.flush

    object_store2 = ObjectStore.new(marshal_helper, "foo") { SparseVector.new }
    object_store2[42].to_a.should == [[0,1],[1,1],[2,1]]
p  end
end