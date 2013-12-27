$LOAD_PATH.unshift( File.join( File.dirname( File.dirname(__FILE__)), 'lib' ) )
require 'tuple_logger'
require 'stringio'
require 'token'

describe TupleLogger do

  describe "#log" do

    before do
      @log = StringIO.new
      @logger = TupleLogger.new(@log, 5) 
    end

    def prototype_a
      [Token::Category, Token::Url.new("http://example.com"), Token::Category]
    end
    def prototype_b
      [Token,Token,Token]
    end
    def tuple_a
      [Token::Category.new("a1"), Token::Url.new("http://example.com"), Token::Category.new("a3")]
    end
    def tuple_b
      [Token::Category.new("b1"), Token::Url.new("http://example.com"), Token::Category.new("b3")]
    end

    it "doens't log anything when nothing was logged" do
      @logger.close
      @log.string.should == ""
    end
    
    it "doesn't log anything until closed" do
      @logger.log(prototype_a, tuple_a)
      @log.string.should == ""
    end
    
    it "logs a tuple" do
      @logger.log(prototype_a, tuple_a)
      @logger.close
      @log.string.should == "#{prototype_a.to_s}: 1\n#{tuple_a.to_s}\n"
    end

    it "should only log 5 tuples" do
      10.times do
        @logger.log(prototype_a, tuple_a)
      end
      @logger.close
      lines = @log.string.split("\n")
      lines.length.should == 6
      lines[0].should == "#{prototype_a.to_s}: 10"
      lines[1].should == "#{tuple_a.to_s}"
    end

    it "should handle two prototypes" do
      @logger.log(prototype_a, tuple_a)
      @logger.log(prototype_b, tuple_b)
      @logger.close
      lines = @log.string.split("\n")
      lines.length.should == 4
      lines[0].should == "#{prototype_a.to_s}: 1"
      lines[1].should == "#{tuple_a.to_s}"
      lines[2].should == "#{prototype_b.to_s}: 1"
      lines[3].should == "#{tuple_b.to_s}"
    end
  end
  
end
