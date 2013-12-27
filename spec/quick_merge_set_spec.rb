$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'quick_merge_set'

describe QuickMergeSet do

  it { QuickMergeSet.new([]).merge([]).to_a == [] }
  it { QuickMergeSet.new([1,2,3]).merge([]).to_a == [1,2,3] }
  it { QuickMergeSet.new([]).merge([1,2,3]).to_a == [1,2,3] }
  it { QuickMergeSet.new([1]).merge([1]).to_a == [1] }
  it { QuickMergeSet.new([1,2,3]).merge([4,5,6]).to_a == [1,2,3,4,5,6] }
  it { QuickMergeSet.new([2,4,6]).merge([1,3,5]).to_a == [1,2,3,4,5,6] }
  it { QuickMergeSet.new([2,4,6]).merge([1,2,3]).to_a == [1,2,3,4,6] }

end
