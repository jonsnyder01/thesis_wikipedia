$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'token'

describe Token do

  describe "#hash" do
    it "two identical tokens should have the same hash" do
      Token.new("foo").hash.should == Token.new("foo").hash
    end

  end

  describe "#eql?" do
    it "two identical tokens should be eql?" do
      Token.new("foo").eql?(Token.new("foo")).should == true
    end
    it "subclass should not be equal" do
      Token.new("foo").eql?(Token::Resource.new("foo").hash).should == false
    end
  end

  it "should work as a key in a hash table" do
    hash = {}
    hash[Token.new("bar")] = "a"
    hash[Token.new("bar")] = "b"
    hash.size.should == 1
    hash[Token.new("bar")].should == "b"
  end

  it "should have the same to_s" do
    Token.new("foo").to_s.should == Token.new("foo").to_s
  end
  
end
