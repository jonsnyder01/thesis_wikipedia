$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'rouge_metric'

describe RougeMetric do

  let(:rouge1) { RougeMetric.new(1) }
  let(:rouge2) { RougeMetric.new(2) }

  it "handles empty reference" do
    rouge1.call([],["Empty"]).should == 0.0
  end
  it "handles bigram one word reference" do
    rouge2.call([["Reference"]],["Hello", "World"]).should == 0.0
  end
  it "handles unigram 100% match" do
    rouge1.call([%w(a b c d e f)], %w(a b c d e f)).should == 1.0
  end
  it "handles bigram 100% match" do
    rouge2.call([%w(a b c d e f)], %w(a b c d e f)).should == 1.0
  end
  it "handles unigram partial match" do
    rouge1.call([%w(a b c d e f)], %w(a b c)).should == 0.5
  end
  it "handles bigram partial match" do
    rouge2.call([%w(a b c d e f)], %w(a b c)).should == 0.4
  end
  it "handles multiple references" do
    rouge2.call([%w(a b c),%w(b c d)], %w(b c z)).should == 0.5
  end

end