$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )

require 'in_memory_marshal_helper'
require 'database_scope'

describe CategoryGateway do

  let(:marshal_helper) { InMemoryMarshalHelper.new }
  let(:database_scope) { DatabaseScope.new(marshal_helper) }
  let(:gateway) { database_scope.category_gateway }

  let(:t_marshal_helper) { InMemoryMarshalHelper.new }
  let(:t_database_scope) { DatabaseScope.new(t_marshal_helper) }
  let(:t_article_sets) { t_database_scope.category_article_sets }

  def article(id)
    return Struct.new(:id).new(id)
  end

  def compare_set_store(set_store, expected)
    set_store.size.should == expected.size
    expected.each_with_index do |e, i|
      set_store[i].to_a.should =~ e
    end
  end
  
  describe "#create" do
    it "requires a slug" do
      expect { gateway.create(title: "Foo") }.to raise_error(ArgumentError)
    end

    it "returns nil" do
      gateway.create(slug: "a", title: "Category A").should be_nil
    end
  end

  describe "#find_by_slug" do
    it "throws an error when it cannot find it" do
      gateway.create(slug: "a", title: "A")
      expect { gateway.find_by_slug(slug: "b") }.to raise_error(NotFound)
    end

    it "returns an object" do
      gateway.create(slug: "a", title: "A")
      gateway.find_by_slug("a")
    end
  end

  describe "#transitive_articles" do
    it "handles no categories" do
      gateway.calculate_transitive_articles(t_article_sets)
      compare_set_store(t_article_sets, [])
    end

    it "handles no child categories or articles" do
      gateway.create(slug: "a", title: "A")
      gateway.create(slug: "b", title: "B")
      gateway.calculate_transitive_articles(t_article_sets)
      compare_set_store(t_article_sets, [[],[]])
    end

    it "handles child categories, but no articles" do
      gateway.create(slug: "a", title: "A")
      gateway.create(slug: "b", title: "B")
      gateway.find_by_slug("a").add_child_category(gateway.find_by_slug("b"))
      gateway.calculate_transitive_articles(t_article_sets)
      compare_set_store(t_article_sets, [[],[]])
    end

    it "handles articles but no child categories" do
      gateway.create(slug: "a", title: "A")
      gateway.create(slug: "b", title: "B")
      gateway.create(slug: "c", title: "C")
      gateway.find_by_slug("a").add_article(article(0))
      gateway.find_by_slug("a").add_article(article(1))
      gateway.find_by_slug("b").add_article(article(2))
      gateway.calculate_transitive_articles(t_article_sets)
      compare_set_store(t_article_sets, [[0,1],[2],[]])
    end
    
    it "handles a small test case" do
      gateway.create(slug: "a", title: "A")
      gateway.create(slug: "b", title: "B")
      gateway.create(slug: "c", title: "C")
      gateway.find_by_slug("a").add_article(article(0))
      gateway.find_by_slug("a").add_article(article(1))
      gateway.find_by_slug("b").add_article(article(2))
      gateway.find_by_slug("a").add_child_category(gateway.find_by_slug("b"))
      gateway.find_by_slug("a").add_child_category(gateway.find_by_slug("c"))
      gateway.calculate_transitive_articles(t_article_sets)
      compare_set_store(t_article_sets, [[0,1,2],[2],[]])
    end
    
    it "handles a loop" do
      gateway.create(slug: "a", title: "A")
      gateway.create(slug: "b", title: "B")
      gateway.create(slug: "c", title: "C")
      gateway.find_by_slug("a").add_article(article(0))
      gateway.find_by_slug("a").add_article(article(1))
      gateway.find_by_slug("b").add_article(article(2))
      gateway.find_by_slug("a").add_child_category(gateway.find_by_slug("b"))
      gateway.find_by_slug("b").add_child_category(gateway.find_by_slug("c"))
      gateway.find_by_slug("c").add_child_category(gateway.find_by_slug("a"))
      gateway.calculate_transitive_articles(t_article_sets)
      compare_set_store(t_article_sets, [[0,1,2],[0,1,2],[0,1,2]])
    end
  end
=begin  
  describe "#subset" do
    it "handles a small test case" do
      article_gateway = ArticleGateway.new(InMemoryMarshalHelper.new)
      subset_article_gateway = ArticleGateway.new(InMemoryMarshalHelper.new)
      subset_category_gateway = CategoryGateway.new(InMemoryMarshalHelper.new)
      
      gateway.create(slug: "a", title: "A")
      gateway.create(slug: "b", title: "B")
      gateway.create(slug: "c", title: "C")
      gateway.create(slug: "d", title: "D")
      article_gateway.create(slug: "art_a", title: "Article A")
      article_gateway.create(slug: "art_b", title: "Article B")
      article_gateway.create(slug: "art_c", title: "Article C")
      article_gateway.create(slug: "art_d", title: "Article D")
      article_gateway.create(slug: "art_e", title: "Article E")
      article_gateway.create(slug: "art_f", title: "Article F")
      
      gateway.find_by_slug("a").add_article(article_gateway.find_by_slug("art_a"))
      gateway.find_by_slug("a").add_article(article_gateway.find_by_slug("art_b"))
      gateway.find_by_slug("b").add_article(article_gateway.find_by_slug("art_c"))
      gateway.find_by_slug("c").add_article(article_gateway.find_by_slug("art_d"))
      gateway.find_by_slug("d").add_article(article_gateway.find_by_slug("art_e"))
      gateway.find_by_slug("d").add_article(article_gateway.find_by_slug("art_f"))
      
      gateway.find_by_slug("a").add_child_category(gateway.find_by_slug("b"))
      gateway.find_by_slug("c").add_child_category(gateway.find_by_slug("d"))
      gateway.calculate_transitive_articles
      gateway.build_subset(article_gateway, subset_article_gateway, subset_category_gateway, gateway.find_by_slug("c").id)

      articles = subset_category_gateway.to_enum(:each_transitive_articles).to_a
      articles.size.should == 2
      articles[0].should =~ [0,1,2]
      articles[1].should =~ [1,2]

      expect { subset_article_gateway.find_by_slug("art_a") }.to raise_error(NotFound)
      expect { subset_article_gateway.find_by_slug("art_b") }.to raise_error(NotFound)
      expect { subset_article_gateway.find_by_slug("art_c") }.to raise_error(NotFound)
      subset_article_gateway.find_by_slug("art_d")
      subset_article_gateway.find_by_slug("art_e")
      subset_article_gateway.find_by_slug("art_f")
    end
  end
=end

end
