$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'dbpedia_tokenizer'

describe DbpediaTokenizer do
  let(:output) do
    output = []
    DbpediaTokenizer.new(input).each_line do |line|
      output << line
    end
    output
  end
  
  context "with resource" do
    let(:input) { ["<http://dbpedia.org/resource/foo>"] }

    it { output.size.should == 1 }
    it { output[0].size.should == 1 }
    it { output[0][0].value.should == "foo" }
    it { output[0][0].should be_instance_of Token::Resource }
  end

  context "with category" do
    let(:input) { ["<http://dbpedia.org/resource/Category:bar>"] }
    it { output[0][0].value.should == "bar" }
    it { output[0][0].should be_instance_of Token::Category }
  end

  context "with ontology" do
    let(:input) { ["<http://dbpedia.org/ontology/42>"] }
    it { output[0][0].value.should == "42" }
    it { output[0][0].should be_instance_of Token::Ontology }
  end

  context "with skos" do
    let(:input) { ["<http://www.w3.org/2004/02/skos/broader>"] }
    it { output[0][0].value.should == "broader" }
    it { output[0][0].should be_instance_of Token::Skos }
  end

  context "with string" do
    let(:input) { ['"Hello World"@en'] }
    it { output[0][0].value.should == "Hello World" }
    it { output[0][0].should be_instance_of Token::String }
  end

  context "with crazy string" do
    let(:input) { ['"I said, \"Hello World\""@en'] }
    it { output[0][0].value.should == 'I said, "Hello World"' }
    it { output[0][0].should be_instance_of Token::String }
  end

  context "with language" do
    let(:input) { ['"Hello"@en'] }
    it { output[0][0].value.should == "Hello" }
  end

  context "with multiple resources" do
    let (:input) { ['<foo> <bar> "baz"'] }
    it { output[0][0].value.should == 'foo' }
    it { output[0][1].value.should == 'bar' }
    it { output[0][2].value.should == 'baz' }
  end

  context "with garbage between" do
    let (:input) { ['<foo>bar<baz>'] }
    it {output[0][1].value.should == 'bar' }
  end

  context "with ending dot" do
    let (:input) { ['<foo> <bar> "baz" .'] }
    it {output[0].size.should == 3}
  end

  context "with example file" do
    let (:input) { [
'<http://dbpedia.org/resource/Autism> <http://dbpedia.org/ontology/abstract> "Autism is der."@en .',
'<http://dbpedia.org/resource/Autism> <http://purl.org/dc/terms/subject> <http://dbpedia.org/resource/Category:Autism> .',
'<http://dbpedia.org/resource/Category:Futurama> <http://www.w3.org/2000/01/rdf-schema#label> "Futurama"@en .',
'<http://dbpedia.org/resource/Closest_pair> <http://dbpedia.org/ontology/wikiPageRedirects> <http://dbpedia.org/resource/Closest_pair_of_points_problem> .',
'<http://dbpedia.org/resource/Category:Middle-earth_languages> <http://www.w3.org/2004/02/skos/core#broader> <http://dbpedia.org/resource/Category:Artistic_languages> .']
    }

    it { output[0].to_s.should == [Token::Resource.new("Autism"),Token::Ontology.new("abstract"),Token::String.new("Autism is der.")].to_s }
    it { output[1].to_s.should == [Token::Resource.new("Autism"),Token::Url.new("http://purl.org/dc/terms/subject"),Token::Category.new("Autism")].to_s }
    it { output[2].to_s.should == [Token::Category.new("Futurama"),Token::Url.new("http://www.w3.org/2000/01/rdf-schema#label"),Token::String.new("Futurama")].to_s }
    it { output[3].to_s.should == [Token::Resource.new("Closest_pair"),Token::Ontology.new("wikiPageRedirects"),Token::Resource.new("Closest_pair_of_points_problem")].to_s }
    it { output[4].to_s.should == [Token::Category.new("Middle-earth_languages"),Token::Skos.new("core#broader"),Token::Category.new("Artistic_languages")].to_s }
  end  
end
