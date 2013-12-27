$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'spec' ) )

require 'database_scope'
require 'in_memory_marshal_helper'

describe ArticleGateway do

  let(:marshal_helper) { InMemoryMarshalHelper.new }
  let(:database_scope) { DatabaseScope.new(marshal_helper) }
  let(:gateway) { database_scope.article_gateway }
  let(:fixed_gateway) { database_scope.fixed_article_gateway }

  describe "#create" do
    it "should return nil and not raise error" do
      gateway.create(slug: "foo", title: "Foo").should be_nil
    end

    it "should not accept a nil slug" do
      expect { gateway.create(title: "Foo", slug: nil) }.to raise_error(ArgumentError)
    end

    it "should require a slug" do
      expect { gateway.create(title: "Foo") }.to raise_error(ArgumentError)
    end
  end

  describe "#find_by_slug" do
    it "should raise error when not found" do
      gateway.create(slug: "foo", title: "Foo")
      expect { gateway.find_by_slug("bar") }.to raise_error(NotFound)
    end

    it "should return an object when found" do
      gateway.create(slug: "foo", title: "Foo")
      gateway.find_by_slug("foo").should_not be_nil
    end
  end

  describe "#write_pipeline_file and #flush" do
  
    def as_json
      file = StringIO.new
      fixed_gateway.write_pipeline_file(file)
      file.string.split("\n").map do |line|
        JSON.parse(line)
      end
    end
    
    context "with just titles imported" do
      before do
        gateway.create(slug: "foo", title: "Foo")
        gateway.create(slug: "bar", title: "Bar")
      end
      
      it "it doesn't output anything" do
        as_json.should =~ []
      end
    end
    
    context "with just abstracts imported" do
      before do
        gateway.create(slug: "foo", text: "Foo")
        gateway.create(slug: "bar", text: "Bar")
      end
      it "it doesn't output anything" do
        as_json.should =~ []
      end
    end
    
    context "with titles and abstracts imported" do
      before do
        gateway.create(slug: "foo", title: "Foo")
        gateway.create(slug: "bar", title: "Bar")
        gateway.create(slug: "no_text", title: "No Text")
        gateway.create(slug: "foo", text: "Foo text.")
        gateway.create(slug: "bar", text: "Bar text.")
        gateway.create(slug: "no_title", text: "No Title")
      end
      let (:expected) { [{"id"=>0, "title"=>"Foo", "text"=>"Foo text."},{"id"=>1, "title"=>"Bar", "text"=>"Bar text."}] }
      
      it "combines the output" do
        as_json.should =~ expected
      end
    end

    
    context "with aliases imported" do
      before do
        gateway.create(slug: "foo", title: "Foo")
        gateway.create(slug: "bar", title: "Bar")
        gateway.create(slug: "foo", text: "Foo text.")
        gateway.create(slug: "bar", text: "Bar text.")
        gateway.find_by_slug("foo").add_alias("foofoo")
        gateway.find_by_slug("bar").add_alias("barbar")
      end

      it "finds the object given an alias" do
        gateway.find_by_slug("foofoo").should_not be_nil
      end

    end
  end

end
