$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )

require 'database_scope'
require 'in_memory_marshal_helper'

describe SimpleArticleGateway do

  let(:marshal_helper) { InMemoryMarshalHelper.new }
  let(:database_scope) { DatabaseScope.new(marshal_helper) }
  let(:gateway) { database_scope.article_gateway }
  let(:simple_gateway) { database_scope.simple_article_gateway }

  let(:subset_marshal_helper) { InMemoryMarshalHelper.new }
  let(:subset_database_scope) { DatabaseScope.new(subset_marshal_helper) }
  let(:subset_simple_gateway) { subset_database_scope.simple_article_gateway }

  def as_json
    file = StringIO.new
    subset_simple_gateway.write_pipeline_file(file)
    file.string.split("\n").map do |line|
      JSON.parse(line)
    end
  end

  describe "#create" do
    it "handles an empty db" do
      as_json.should == []
    end

    it "allows you to create new articles" do
      subset_simple_gateway.create("Hello","Hello Kitty")
      subset_simple_gateway.create("Goodbye","Goodbye Puppy")
      as_json.should == [
        {"id" => 0, "title" => "Hello", "text" => "Hello Kitty"},
        {"id" => 1, "title" => "Goodbye", "text" => "Goodbye Puppy"}
      ]
    end
  end

  describe "#subset" do
    before do
      gateway.create(slug: 'a', title: 'A')
      gateway.create(slug: 'a', text: 'AAAA')
      gateway.create(slug: 'b', title: 'B')
      gateway.create(slug: 'b', text: 'BBBB')
      gateway.create(slug: 'c', title: 'C')
      gateway.create(slug: 'c', text: 'CCCC')
      gateway.create(slug: 'd', title: 'D')
      gateway.create(slug: 'd', text: 'DDDD')
    end
    
    it "copies all data on a full subset" do
      simple_gateway.subset(subset_simple_gateway, [0,1,2,3])
      as_json.should == [
        {"id" => 0, "title" => 'A', "text" => 'AAAA'},
        {"id" => 1, "title" => 'B', "text" => 'BBBB'},
        {"id" => 2, "title" => 'C', "text" => 'CCCC'},
        {"id" => 3, "title" => 'D', "text" => 'DDDD'}
      ]
    end

    it "re-orders data according to input" do
      simple_gateway.subset(subset_simple_gateway, [2,1,0,3])
      as_json.should == [
        {"id" => 0, "title" => 'C', "text" => 'CCCC'},
        {"id" => 1, "title" => 'B', "text" => 'BBBB'},
        {"id" => 2, "title" => 'A', "text" => 'AAAA'},
        {"id" => 3, "title" => 'D', "text" => 'DDDD'}
      ]
    end

    it "copies only a subset of the data" do
      simple_gateway.subset(subset_simple_gateway, [3,1])
      as_json.should == [
        {"id" => 0, "title" => 'D', "text" => 'DDDD'},
        {"id" => 1, "title" => 'B', "text" => 'BBBB'}
      ]
    end

    it "handles an empty subset" do
      simple_gateway.subset(subset_simple_gateway, [])
      as_json.should == []
    end
  end

end
