$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )

require 'top_n_filter'

describe TopNFilter do

  def addTestData(subject)
    subject.add(1) {'a'}
    subject.add(2) {'b'}
    subject.add(10) {'c'}
    subject.add(3) {'d'}
    subject.add(1) {'e'}
  end

  def all(subject)
    subject.top.to_a
  end

  it "should return nothing initially" do
    subject = TopNFilter.new(3)
    all(subject).should == []
  end

  it "works with one" do
    subject = TopNFilter.new(3)
    subject.add(1) {'foo'}
    all(subject).should == [[1, "foo"]]
  end

  it "works with 5" do
    subject = TopNFilter.new(3)
    addTestData(subject)
    all(subject).should == [[10,"c"],[3,"d"],[2,"b"]]
  end

  it "deduplicates" do
    subject = TopNFilter.new(2)
    subject.add(10) {'a'}
    subject.add(5) {'b'}
    subject.add(4) {'c'}
    subject.add(10) {'a'}
    all(subject).should == [[10,'a'],[5,'b']]
  end
end