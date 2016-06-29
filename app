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
    annotator = NltkSentenceAnnotator.new("#{directory}/tmp")
    db = DatabaseScope.new(MarshalHelper.new(directory))
    db.logging_simple_category_gateway.annotate_all(annotator)
    db.category_annotations.flush
    db.logging_simple_article_gateway.annotate_all(annotator)
    db.article_annotations.flush
  when "extract_phrases"
    require 'marshal_helper'
    require 'database_scope'
    require 'nltk_phrase_extractor'
    directory = ARGV.shift
    extractor = NltkPhraseExtractor.new("#{directory}/tmp")
    db = DatabaseScope.new(MarshalHelper.new(directory))
    db.logging_simple_article_gateway.extract_phrases(extractor)
    db.article_phrases.flush
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
    db.topic_mallet_topics.clear
    command = MalletCommand.new(db.logging_simple_article_gateway, db.stopwords, working_directory, db.topic_gateway, topics: topics, iterations: iterations)
    command.run
    db.topic_mallet_topics.flush
    db.article_annotations.flush
  when "gold_standard"
    require 'marshal_helper'
    require 'database_scope'
    require 'cosine_similarity'
    directory = ARGV.shift
    confidence = ARGV.shift.to_f
    measure = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    puts "Computing Category Vectors:"
    db.topic_gateway.compute_category_vectors(db.simple_article_gateway, confidence)
    puts "Computing Matching Categories"
    #db.topic_gateway.compute_matching_categories(db.simple_category_gateway, CosineSimilarity, db.simple_article_gateway.size)
    db.topic_gateway.compute_matching_categories_binary_measure(db.simple_category_gateway, db.simple_article_gateway.size, measure)
    db.topic_category_vectors.flush
    db.topic_category_similarity_vectors.flush
  when "top_categories"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    db.topic_gateway.print_top_categories_report(db.simple_category_gateway)
  when "create_phrases"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    type = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    if type == "n_gram"
      db.counting_phrase_store.create_n_gram_phrases(db.simple_article_gateway, ARGV.shift.to_i)
    elsif type == "noun"
      db.counting_phrase_store.create_noun_phrases(db.simple_article_gateway)
    end
    db.counting_phrase_store.flush
  when "evaluate_labelers"
    require 'marshal_helper'
    require 'database_scope'
    directory = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)

    labeler = ARGV.shift
    case(labeler)
      when "first_order"
        require 'topic_vector_generator'
        require 'hybrid_first_order_labeler'
        topic_vector_generator = TopicVectorGenerator.new(db.simple_article_gateway)
        labeler =  HybridFirstOrderLabeler.new(db.simple_article_gateway, db.counting_phrase_store.counting_phrase,
                                               topic_vector_generator.frequency_topic_vectors, 10)
        file_name = "first_order"
      when "cheating"
        require 'cheating_labeler'
        labeler = CheatingLabeler.new(db.counting_phrase_store.counting_phrase)
        file_name = "cheating"
      when "cosine"
        require 'topic_vector_generator'
        require 'cosine_similarity_labeler'
        topic_vector_generator = TopicVectorGenerator.new(db.simple_article_gateway)
        vectors_name = ARGV.shift
        vectors = topic_vector_generator.send("#{vectors_name}_topic_vectors")
        boost_name = ARGV.shift
        case boost_name
          when "none"
            boost_function = Proc.new { |freq| 1 }
          when "log"
            boost_function = Proc.new { |freq| Math.log(freq + 1) }
          when "sqrt"
            boost_function = Proc.new { |freq| Math.sqrt(freq) }
          when "linear"
            boost_function = Proc.new { |freq| freq }
        end
        labeler = CosineSimilarityLabeler.new(db.counting_phrase_store.counting_phrase,
                                              vectors, boost_function, 10)
        file_name = "cosine_#{vectors_name}_#{boost_name}"
    end

    #File.open("#{directory}/#{file_name}.txt", "w") do |file|
    #  file.puts "Test"
    #end
    db.topic_gateway.evaluate_labeler2(
        labeler, db.simple_category_gateway, "#{directory}/#{file_name}.txt")

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
    t = 0
    db.simple_article_gateway.each do |article|
      article.sentence_annotations.each do |sentence|
        t += sentence.tokens.size
      end
    end
    puts "Tokens: #{t}"

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
  when "test_categories_in_body"
    require 'marshal_helper'
    require 'database_scope'
    require 'word_trie'
    directory = ARGV.shift
    input = MarshalHelper.new(directory)
    db = DatabaseScope.new(input)
    trie = WordTrie.new
    counts = {}
    db.simple_category_gateway.each do |category|
      trie.add(category.annotation.tokens)
      counts[category.annotation.tokens.join(" ")] = 0
    end
    db.simple_article_gateway.each do |article|
      article.sentence_annotations.each do |sentence|
        trie.count(sentence.tokens, counts)
      end
    end
    p counts.size
    p (counts.reduce(0) { |zeros, (key, value)| value == 0 ? zeros : zeros + 1 })
    p counts.sort_by { |key, value| value }
  else
    STDERR.puts "Unknown command #{command}"
end







