#!/usr/bin/env ruby
$LOAD_PATH.unshift( File.join( File.dirname(__FILE__)), 'lib' )

command = ARGV.shift

case command
when "import"
  require 'import_scope'
  file_type = ARGV.shift
  database = ARGV.shift
  
  application_scope = ImportScope.new(STDIN, database)
  application_scope.importer.import(file_type.to_sym)
  db = application_scope.database_scope
  db.article_slugs.flush
  db.article_titles.flush
  db.article_texts.flush
  db.category_slugs.flush
  db.category_titles.flush
  db.category_article_sets.flush
  db.category_child_category_sets.flush
when "calculate_transitive"
  require 'input_output_scope'
  input_directory = ARGV.shift
  output_directory = ARGV.shift
  category_slug = ARGV.shift
  depth = ARGV.shift.to_i
  
  scope = InputOutputScope.new(input_directory, output_directory)
  scope.calculate_transitive_command.run(category_slug, depth)
  scope.output_database.logging_category_article_sets.flush
when "link"
  require 'marshal_helper'
  input_directory = ARGV.shift
  output_directory = ARGV.shift
  input = MarshalHelper.new(input_directory)
  output = MarshalHelper.new(output_directory)
  input.link('article_texts',output)
  input.link('article_titles',output)
  input.link('category_slugs',output)
  input.link('category_titles',output)
when "subset"
  require 'input_output_scope'
  input_directory = ARGV.shift
  output_directory = ARGV.shift
  category_slug = ARGV.shift
  minimum_category_size = ARGV.shift.to_i
  scope = InputOutputScope.new(input_directory, output_directory)
  category_id = scope.input_database.category_slugs.find_id_by_slug(category_slug)
  raise ArgumentError.new("Cound not find #{category_slug}") unless category_id
  
  scope.subset_command.run(category_id, minimum_category_size)
  scope.output_database.article_titles.flush
  scope.output_database.article_texts.flush
  scope.output_database.category_titles.flush
  scope.output_database.category_article_sets.flush
else
  STDERR.puts "Unknown command #{command}"
end







