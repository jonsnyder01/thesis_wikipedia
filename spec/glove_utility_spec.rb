$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'glove_utility'

describe GloveUtility do

  subject { GloveUtility.new(StringIO.open("b 1.0 -3.0\na -5.0 7.0\nc 0.0 2.0\n", "r")) }

  it "finds c" do
    subject.find_words({"c" => true}) do |word, vector|
      word.should == "c"
      vector.should == [0.0, 2.0]
    end
  end

  it "finds b and a but not d" do
    out = {}
    subject.find_words("a" => true, "b" => false, "d" => true) do |word, vector|
      out[word] = vector
    end
    out.should == {"a" => [-5.0, 7.0],"b" => [1.0, -3.0]}
  end

  it "find nearest neighbors" do
    subject.nearest_neighbors([1, -3], 2).should == [[0.0, "b", [1.0, -3.0]],[26, "c", [0.0, 2.0]]]
  end

end