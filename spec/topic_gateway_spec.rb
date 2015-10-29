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
  def parse(texts)
    p texts
    texts.map do |id, double|
      text = double.value
      words = text.split(' ')
      a = SentenceAnnotations.new(text, words.size, Array.new(words.size, "P"))
      if id == 0
        a.topics = [0,0,0,1]
      elsif id == 1
        a.topics = [2,1,1,1]
      elsif id == 2
        a.topics = [0,1,2,0]
      end
      [id, [a]]
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

    article_gateway.create(double(value: "ABCD"), double(value: "a b c d"))
    article_gateway.create(double(value: "EFGH"), double(value: "e f g h"))
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

  it { category_vectors[0].should == [0] }
  it { category_vectors[1].should == [1] }
  it { category_vectors[2].should == [] }

  context "with computed matching categories" do
    let(:similarity_measure) { CosineSimilarity }
    let(:category_gateway) do
      titles = ObjectStore.new(marshal_helper, 'category_titles')
      article_sets = ObjectStore.new(marshal_helper, 'article_sets')
      annotations = ObjectStore.new(marshal_helper, 'category_annotations')
      category_gateway = SimpleCategoryGateway.new(titles, article_sets, annotations)

      category_gateway.create(title: "Category 0", article_set: [0])
      category_gateway.create(title: "Category 01", article_set: [0, 1])
      category_gateway.create(title: "Category 02", article_set: [0, 2])
      category_gateway.create(title: "Category 12", article_set: [1, 2])
      category_gateway.create(title: "Category 012", article_set: [0, 1, 2])

      category_gateway
    end

    before do
      topic_gateway.compute_matching_categories_binary_measure(category_gateway,article_gateway.size)
    end

    it {
      topic_gateway.print_top_categories_report(category_gateway)
    }

  end

end
