require 'database_scope'
require 'marshal_helper'
require 'logging_object_store'
require 'calculate_transitive_command'
require 'subset_command'

class InputOutputScope

  def initialize(input_directory, output_directory)
    @input_directory = input_directory
    @output_directory = output_directory
  end

  def calculate_transitive_command
    CalculateTransitiveCommand.new(input_database.category_gateway, output_database.logging_transitive_category_article_sets)
  end

  def subset_command
    SubsetCommand.new(
      input_database.simple_article_gateway,
      input_database.simple_category_gateway,
      output_database.logging_simple_article_gateway,
      output_database.logging_simple_category_gateway
      )
  end

  def input_database
    @input_database ||= DatabaseScope.new(input_marshal_helper)
  end

  def input_marshal_helper
    @input_marshal_helper ||= MarshalHelper.new(@input_directory)
  end

  def output_database
    @output_database ||= DatabaseScope.new(output_marshal_helper)
  end

  def output_marshal_helper
    @output_marshal_helper ||= MarshalHelper.new(@output_directory)
  end

end
