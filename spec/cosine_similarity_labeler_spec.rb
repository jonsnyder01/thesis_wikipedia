$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'cosine_similarity_labeler'
require 'sentence_annotations'
require 'simple_article_gateway'

describe CosineSimilarityLabeler do
  it "works" do
    topic_vectors = {3 => {'a' => 1,
                           'b' => 2,
                           'c' => 3,
                           'd' => 10,
                           'e' => 1,
                           'f' => 0,
                           'g' => 1}}
    titles = ['alphabet']
    texts = ['a b c d e f g']
    annotations = [[SentenceAnnotations.new('a b c d e f g',['a','b','c','d','e','f','g'],nil)]]
    article_gateway = SimpleArticleGateway.new(titles, texts, annotations)
    subject = CosineSimilarityLabeler.new(article_gateway, topic_vectors, 4)
    topic = double(id: 3)
    subject.call(topic).to_a.should == ['d','c d', 'b c d', 'c d e']
  end
end