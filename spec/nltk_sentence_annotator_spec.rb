$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )
require 'nltk_sentence_annotator'
require 'sentence_annotator_examples'

describe NltkSentenceAnnotator do

  let(:annotator) { NltkSentenceAnnotator.new("spec/tmp") }

  before { Dir.mkdir("spec/tmp") if !Dir.exists?("spec/tmp") }
  after { FileUtils.rm_rf("spec/tmp") }

  it_behaves_like "a sentence annotator"

  it "parses category titles" do
    annotator.tokenize([[1,"Hello World"],[2, "Goodbye (Kitty)"]]).to_a.should == [[1,["hello","world"]],[2,["goodbye","kitty"]]]
  end
end
