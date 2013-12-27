$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'dbpedia_parser'
require 'dbpedia_tokenizer'
require 'tuple_logger'
require 'stringio'

describe DbpediaParser do

  let(:log) { StringIO.new }
  let(:logger) { TupleLogger.new(log,5) }
  let(:status_log) { StringIO.new }
  let(:tokenizer) { DbpediaTokenizer.new(input) }
  let(:parser) { DbpediaParser.new(tokenizer, logger, status_log) }
  let(:log_output) do
    log.string
  end
  
  context "with no exceptions" do
    let!(:matches) do
      matches = []
      parser.scan(pattern) do |tuple|
        matches << tuple
      end
      matches
    end
  
    context "with one row" do
      let(:input) { ["<a> <a> <a>"] }
      let(:pattern) { [Token, Token, Token] }
      it { matches.length.should == 1 }
      it { matches[0].to_s.should == [Token::Url.new("a"), Token::Url.new("a"), Token::Url.new("a")].to_s }
      it { log_output.should == "" }
    end
    
    context "with a row that doesn't match" do
      let(:input) { ["<a> <b> <c>"] }
      let(:pattern) { [Token, Token::Url.new("a"), Token] }
      it { matches.length.should == 0 }
      it { log_output.should == "#{[Token,nil,Token].to_s}: 1\n#{[Token::Url.new('a'),Token::Url.new('b'),Token::Url.new('c')].to_s}\n\n" }
    end
  end
  context "with exception" do
    let(:input) { ["<a> <a> <a>"] }
    let(:pattern) { [Token,Token,Token] }
    
    before do
      parser.scan(pattern) do |tuple|
        raise "Foo"
      end
    end

    it { log_output.should == "Foo: 1\n#{[Token::Url.new('a'),Token::Url.new('a'),Token::Url.new('a')].to_s}\n\n" }
  end
end
