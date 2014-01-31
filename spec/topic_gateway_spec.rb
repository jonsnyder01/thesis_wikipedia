$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )

require 'in_memory_marshal_helper'
require 'object_store'
require 'simple_article_gateway'
require 'simple_category_gateway'
require 'topic_gateway'
require 'mallet_topic'
require 'sentence_annotations'
require 'cosine_similarity'

class SimpleAnnotator
  def initialize
    @last_topic = 2
  end
  def parse(text)
    sentences = text.split('.')
    sentences.map do |sentence|
      words = sentence.split(' ')
      a = SentenceAnnotations.new(sentence, words.size, Array.new(words.size, "P"))
      a.topics = Array.new(words.size) { @last_topic = (@last_topic + 1) % 3 }
      a
    end
  end
end

describe TopicGateway do

  let(:marshal_helper) do
    InMemoryMarshalHelper.new
  end

  let(:article_gateway) do
    titles = ObjectStore.new(marshal_helper,'titles')
    texts = ObjectStore.new(marshal_helper,'texts')
    annotations = ObjectStore.new(marshal_helper,'annotations')
    article_gateway = SimpleArticleGateway.new(titles, texts, annotations)

    article_gateway.create(double(value: "ABCD"), double(value: "a b c. d"))
    article_gateway.create(double(value: "EFGH"), double(value: "e f. g h"))
    article_gateway.create(double(value: "IJKL"), double(value: "i j k l"))

    article_gateway.annotate_all(SimpleAnnotator.new)

    article_gateway
  end

  let(:category_vectors) { ObjectStore.new(marshal_helper,'category_vectors') }
  let(:category_similarity_vectors) { ObjectStore.new(marshal_helper,'category_similarity_vectors') }

  let(:topic_gateway) do
    mallet_data = ObjectStore.new(marshal_helper,'mallet_data')
    topic_gateway = TopicGateway.new(mallet_data, category_vectors, category_similarity_vectors)

    topic_gateway.create(MalletTopic.new(nil, nil, "0", nil))
    topic_gateway.create(MalletTopic.new(nil, nil, "1", nil))
    topic_gateway.create(MalletTopic.new(nil, nil, "2", nil))

    topic_gateway
  end

  before do
    topic_gateway.compute_category_vectors(article_gateway)
  end

  it { category_vectors[0].should == [0.50, 0.25, 0.25] }
  it { category_vectors[1].should == [0.25, 0.50, 0.25] }
  it { category_vectors[2].should == [0.25, 0.25, 0.50] }

  context "with computed matching categories" do
    let(:similarity_measure) { CosineSimilarity }
    let(:category_gateway) do
      titles = ObjectStore.new(marshal_helper, 'category_titles')
      article_sets = ObjectStore.new(marshal_helper, 'article_sets')
      category_gateway = SimpleCategoryGateway.new(titles, article_sets)

      category_gateway.create(title: "Category 0", article_set: [0])
      category_gateway.create(title: "Category 01", article_set: [0, 1])
      category_gateway.create(title: "Category 02", article_set: [0, 2])
      category_gateway.create(title: "Category 12", article_set: [1, 2])
      category_gateway.create(title: "Category 012", article_set: [0, 1, 2])

      category_gateway
    end

    before do
      topic_gateway.compute_matching_categories(category_gateway,similarity_measure,article_gateway.size)
    end

    it {category_similarity_vectors[0][0].should == CosineSimilarity.call([1,0,0], [0.50, 0.25, 0.25])}
    it {category_similarity_vectors[1][2].should == CosineSimilarity.call([1,0,1], [0.25, 0.50, 0.25])}
    it {category_similarity_vectors[2][4].should == CosineSimilarity.call([1,1,1], [0.25, 0.25, 0.50])}

  end

end