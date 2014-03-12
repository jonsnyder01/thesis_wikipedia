$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )
require 'stanford_sentence_annotator'
require 'sentence_annotator_examples'

describe StanfordSentenceAnnotator do

  let(:annotator) { StanfordSentenceAnnotator.new }

  it_behaves_like "a sentence annotator"
end
