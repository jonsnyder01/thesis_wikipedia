$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'quick_merge_set'
require 'benchmark'
require 'set'

def make_set
  set = Set.new
  1000000.times { set.add(Random.rand(1000000)) }
  set
end

set1 = make_set
set2 = make_set
a1 = set1.to_a
a2 = set2.to_a
qset1 = QuickMergeSet.new(a1.sort)
qset2 = QuickMergeSet.new(a1.sort)

Benchmark.bmbm do |x|
  x.report("Set")            { set1.merge(set2) }
  x.report("QuickMergeSet")  { qset1.merge(qset2) }
  x.report("|")              { a1 | a2 } 
end
