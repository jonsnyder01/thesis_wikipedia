$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )

require 'in_memory_marshal_helper'
require 'database_scope'

describe SimpleCategoryGateway do

  let(:marshal_helper) { InMemoryMarshalHelper.new }
  let(:database_scope) { DatabaseScope.new(marshal_helper) }
  let(:gateway) { database_scope.category_gateway }

  let(:t_marshal_helper) { InMemoryMarshalHelper.new }
  let(:t_database_scope) { DatabaseScope.new(t_marshal_helper) }
  let(:t_article_sets) { t_database_scope.transitive_category_article_sets }

  let(:simple_gateway) { SimpleCategoryGateway.new(database_scope.category_titles, t_article_sets) }

  let(:subset_marshal_helper) { InMemoryMarshalHelper.new }
  let(:subset_database_scope) { DatabaseScope.new(subset_marshal_helper) }
  let(:subset_gateway) { subset_database_scope.simple_category_gateway }

  def article(id)
    return Struct.new(:id).new(id)
  end

  def subset_as_json
    file = StringIO.new
    subset_gateway.write_pipeline_file(file)
    file.string.split("\n").map do |line|
      JSON.parse(line)
    end
  end
  
  describe "#subset" do
    it "handles a small test case" do
      
      gateway.create(slug: "a", title: "A")
      gateway.create(slug: "b", title: "B")
      gateway.create(slug: "c", title: "C")
      gateway.create(slug: "d", title: "D")
      
      gateway.find_by_slug("a").add_article(article(0))
      gateway.find_by_slug("a").add_article(article(1))
      gateway.find_by_slug("b").add_article(article(2))
      gateway.find_by_slug("c").add_article(article(3))
      gateway.find_by_slug("d").add_article(article(4))
      gateway.find_by_slug("d").add_article(article(5))
      
      gateway.find_by_slug("a").add_child_category(gateway.find_by_slug("b"))
      gateway.find_by_slug("c").add_child_category(gateway.find_by_slug("d"))
      gateway.calculate_transitive_articles(t_article_sets)

      id = gateway.find_by_slug("c").id
      simple_gateway[id].articles.to_a.should == [[3,1],[4,2],[5,2]]
      simple_gateway[gateway.find_by_slug("d").id].articles.to_a.should == [[4,1],[5,1]]
      
      simple_gateway.subset(subset_gateway, id, 1)
      subset_as_json.should == [
        {"id" => 0, "title" => "C", "articles" => [[0,1],[1,2],[2,2]]},
        {"id" => 1, "title" => "D", "articles" => [[1,1],[2,1]]}
      ]
    end
  end

end
