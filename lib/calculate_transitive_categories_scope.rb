require 'database_scope'
require 'marshal_helper'
require 'logging_object_store'
require 'calculate_transitive_command'

class CalculateTransitiveScope

  def initialize(input_directory, output_directory)
    @input_directory = input_directory
    @output_directory = output_directory
  end

  def command
    CalculateTransitiveCommand.new(input_database.category_gateway, logging_article_sets_store)
  end

  def logging_article_sets_store
    LoggingObjectStore.new(output_database.category_article_sets, STDERR)
  end

  def input_database
    DatabaseScope.new(input_marshal_helper)
  end

  def input_marshal_helper
    MarshalHelper.new(@input_directory)
  end

  def output_database
    DatabaseScope.new(output_marshal_helper)
  end

  def output_marshal_helper
    MarshalHelper.new(@output_directory)
  end
end
