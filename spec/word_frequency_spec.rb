$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'word_frequency'

describe WordFrequency do

  subject { WordFrequency.new }
  let(:other) { WordFrequency.new }

  it 'computes cross entropy' do
    subject.add('a');
    subject.add('b');
    other.add('b');
    other.add('c');
    subject.cross_entropy(other).should == 0 - (0.5 * Math.log(0.5)) - (0.5 * Math.log(0.25))

  end
end