$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'topic_counts'

describe TopicCounts do

  def subject(*topic_counts)
    subject = TopicCounts.new
    topic_counts.each_with_index do |topic_count, i|
      topic_count.times do
        subject.inc(i)
      end
    end
    subject.statistically_significant_vector(topic_counts.count)
  end


  it "calculates the vector correctly" do
    subject(10,0).should == [1,0]
    subject(10,10,10).should == [0,0,0]
    subject(4,4,8,4).should == [0,0,1,0]
    subject(8,7,5,0).should == [1,0,0,0]
    subject(2,8,8,2).should == [0,1,1,0]
  end
end

