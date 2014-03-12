$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )
require 'nltk_sentence_annotator'
require 'sentence_annotator_examples'

describe NltkSentenceAnnotator do

  let(:annotator) { NltkSentenceAnnotator.new("spec/tmp") }

  before { Dir.mkdir("spec/tmp") if !Dir.exists?("spec/tmp") }
  after { FileUtils.rm_rf("spec/tmp") }

  it_behaves_like "a sentence annotator"
end
