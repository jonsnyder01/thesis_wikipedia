$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'incremental_cosine_similarity'

describe IncrementalCosineSimilarity do
  subject { IncrementalCosineSimilarity.new }

  it "starts at nan" do
    subject.similarity.nan?.should == true
  end
  it "handles 1 token" do
    subject.add("I", 10)
    subject.similarity.should == 10
  end
  it "handles 5 tokens" do
    subject.add("i", 5)
    subject.similarity.should == 5.0
    subject.add("like", 2)
    subject.similarity.should == 7.0 / Math.sqrt(2)
    subject.add("to", 0)
    subject.similarity.should == 7.0 / Math.sqrt(3)
    subject.add("eat", 4)
    subject.similarity.should == 11.0 / Math.sqrt(4)
    subject.add("hotdogs", 10)
    subject.similarity.should == 21.0 / Math.sqrt(5)
  end
  it "handles a duplicate token" do
    subject.add("truth",5)
    subject.similarity.should == 5
    subject.add("is",1)
    subject.similarity.should == 6.0 / Math.sqrt(2)
    subject.add("truth",5)
    subject.similarity.should == 11.0 / Math.sqrt(5)
  end

  it "remove works" do
    subject.add("i", 5)
    subject.similarity.should == 5.0
    subject.add("like", 2)
    subject.tokens.should == ["i","like"]
    subject.similarity.should == 7.0 / Math.sqrt(2)

    subject.remove("like", 2)
    subject.similarity.should == 5.0
    subject.add("am", 3)
    subject.similarity.should == 8.0 / Math.sqrt(2)
    subject.tokens.should == ["i","am"]
  end
end