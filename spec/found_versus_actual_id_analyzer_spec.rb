$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'found_versus_actual_id_analyzer'


describe FoundVersusActualIdAnalyzer do
  def m(false_negative, true_negative, true_positive, false_positive)
    {false_negative: false_negative, true_negative: true_negative,
     true_positive: true_positive, false_positive: false_positive}
  end

  it { FoundVersusActualIdAnalyzer.call([],[],0).should == m(0,0,0,0) }
  it { FoundVersusActualIdAnalyzer.call([],[],10).should == m(0,10,0,0) }
  it { FoundVersusActualIdAnalyzer.call([],[1,2],3).should == m(2,1,0,0) }
  it { FoundVersusActualIdAnalyzer.call([3,4],[1,3],4).should == m(1,1,1,1) }
  it { FoundVersusActualIdAnalyzer.call([1,2,3,4,5,6,7],[1,2,3,8],10).should == m(1,2,3,4) }


end