require 'importer'
require 'dbpedia_parser'
require 'dbpedia_tokenizer'
require 'tuple_logger'
require 'database_scope'
require 'marshal_helper'

class ImportScope

  def initialize(input_file, database_directory)
    @input_file = input_file
    @database_directory = database_directory
  end
  
  def importer
    @importer ||= Importer.new(dbpedia_parser, database_scope.article_gateway, database_scope.category_gateway)
  end

  def dbpedia_parser
    @dbpedia_parser ||= DbpediaParser.new(dbpedia_tokenizer,tuple_logger,STDERR)
  end

  def dbpedia_tokenizer
    @dbpedia_tokenizer ||= DbpediaTokenizer.new(@input_file)
  end

  def tuple_logger
    @tuple_logger ||= TupleLogger.new(STDERR,10)
  end
  
  def database_scope
    @database_scope ||= DatabaseScope.new(marshal_helper)
  end

  def marshal_helper
    @marshal_Ohelper ||= MarshalHelper.new(@database_directory)
  end

  
end


  
