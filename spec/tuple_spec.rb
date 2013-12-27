$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'token'

describe Token do

  def a
    [Token::Category, Token::Ontology.new("label"), Token::Category]
  end

  def b
    [Token.new("a"),Token.new("b"),Token.new("c")]
  end


  describe "#[]" do
    it "should return the correct value from the tuple" do
      a[0].should == Token::Category
      a[1].eql?(Token::Ontology.new("label")).should == true
      a[2].should == Token::Category
    end
  end
  
  describe "#hash" do
    it "two identical tuples should have the same hash" do
      a.hash.should == a.hash
      b.hash.should == b.hash
    end
  end

  describe "#eql?" do
    it "two identical tuples should be eql?" do
      a.eql?(a).should == true
    end
    it "different tuples should not be equal" do
      a.eql?(b).should == false
    end
  end

  it "should work as a key in a hash table" do
    hash = {}
    hash[a] = "a1"
    hash[b] = "b1"
    hash[a] = "a2"
    hash.size.should == 2
    hash[a].should == "a2"
    hash[b].should == "b1"
  end
  
end
