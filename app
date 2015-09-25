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
    scope.output_database.transitive_category_article_sets.flush
  when "annotate"
    require 'marshal_helper'
    require 'database_scope'
    require 'nltk_sentence_annotator'
    directory = ARGV.shift
    #annotator = StanfordSentenceAnnotator.new
    annotator = NltkSentenceAnnotator.new("#{directory}/tmp")
    db = DatabaseScope.new(MarshalHelper.new(directory))
    db.logging_simple_category_gateway.annotate_all(annotator)
    db.category_annotations.flush
    db.logging_simple_article_gateway.annotate_all(annotator)
    db.article_annotations.flush
  when "json"
    require 'marshal_helper'
    require 'database_scope'
    input_directory = ARGV.shift
    input = MarshalHelper.new(input_directory)
    db = DatabaseScope.new(input)
    input.write('articles.json') do |file|
      db.simple_article_gateway.write_pipeline_file(file)
    end
    input.write('categories.json') do |file|
      db.simple_category_gateway.write_pipeline_file(file)
    end
  when "stopwords"
    require 'marshal_helper'
    require 'set'
    directory = ARGV.shift
    marshal_helper = MarshalHelper.new(directory)
    stopwords = Set.new
    STDIN.each do |line|
      stopwords << line.strip
    end
    marshal_helper.dump(stopwords, 'stopwords')
  when "show_stopwords"
    require 'marshal_helper'
    require 'database_scope'
    require 'set'
    directory = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    db.stopwords.each do |word|
      puts word
    end
  when "mallet"
    require 'marshal_helper'
    require 'database_scope'
    require 'mallet_command'
    directory = ARGV.shift
    topics = ARGV.shift
    iterations = ARGV.shift
    input = MarshalHelper.new(directory)
    working_directory = MarshalHelper.new(File.join(directory, "mallet"))
    db = DatabaseScope.new(input)
    command = MalletCommand.new(db.simple_article_gateway, db.stopwords, working_directory, db.topic_gateway, topics: topics, iterations: iterations)
    command.run
    db.topic_mallet_topics.flush
    db.article_annotations.flush
  when "gold_standard"
    require 'marshal_helper'
    require 'database_scope'
    require 'cosine_similarity'
    directory = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    puts "Computing Category Vectors:"
    db.topic_gateway.compute_category_vectors(db.simple_article_gateway)
    puts "Computing Matching Categories"
    db.topic_gateway.compute_matching_categories(db.simple_category_gateway, CosineSimilarity, db.simple_article_gateway.size)
    db.topic_category_vectors.flush
    db.topic_category_similarity_vectors.flush
  when "top_categories"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    db.topic_gateway.print_top_categories_report(db.simple_category_gateway)
  when "evaluate_labelers"
    require 'top_word_labeler'
    require 'entire_corpus_labeler'
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    puts "Top word labeler (10)"
    db.topic_gateway.evaluate_labeler(TopWordLabeler.new(db.simple_article_gateway, size: 10), db.simple_category_gateway, "#{directory}/top_word.csv")
    puts "All word labeler"
    db.topic_gateway.evaluate_labeler(EntireCorpusLabeler.new(db.simple_article_gateway), db.simple_category_gateway, "#{directory}/entire_corpus.csv")
  when "print"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    store = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    db.send(store).print
  when "print_tokenized"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    store = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    db.send(store).print_tokenized
  when "print_topics"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    store = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    db.send(store).print_topics
  when "stats"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    puts "Articles: #{db.simple_article_gateway.size}"
    puts "Categories: #{db.simple_category_gateway.size}"
    puts "Topics: #{db.topic_gateway.size}"

  when "sentence_matrix"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    output_file = ARGV.shift
    from = ARGV.shift.to_i
    to = ARGV.shift.to_i
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    File.open(output_file,"w") do |file|
      db.simple_article_gateway.print_sentence_matrix(file, from, to)
    end
  else
    STDERR.puts "Unknown command #{command}"
end







