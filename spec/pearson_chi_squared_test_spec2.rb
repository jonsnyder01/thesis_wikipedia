$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )

require 'pearson_chi_squared_test'

describe PearsonChiSquaredTest do

  it { PearsonChiSquaredTest.is_significant(10000, 2500, 1000, 294).should == false }
  it { PearsonChiSquaredTest.is_significant(10000, 2500, 1000, 295).should == true }
end