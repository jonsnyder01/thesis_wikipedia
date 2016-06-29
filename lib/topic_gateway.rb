require 'topic_counts'
require 'rouge_metric'
require 'csv'
#require 'ferret'
#require 'jaccard_index'
#require 'simple_matching_coefficient'
require 'found_versus_actual_id_analyzer'
require 'pearson_chi_squared_test'

class TopicGateway

  class Topic
    attr_accessor :id
    def initialize(mallet_data, category_vectors, category_similarity_vectors)
      @mallet_data = mallet_data
      @category_vectors = category_vectors
      @category_similarity_vectors = category_similarity_vectors
    end

    def mallet_data
      @mallet_data[@id]
    end

    def category_vectors
      @category_vectors[@id]
    end

    def category_similarity_vector
      @category_similarity_vector[@id]
    end

    def sorted_similarity_categories(category_gateway)
      @category_similarity_vectors[@id].each_with_index.sort_by { |sim, id| -sim }.each do |sim, id|
        yield sim, category_gateway[id]
      end
    end
  end


  def initialize(mallet_data, category_vectors, category_similarity_vectors)
    @mallet_data = mallet_data
    @category_vectors = category_vectors
    @category_similarity_vectors = category_similarity_vectors
  end

  def create(mallet_topic)
    @mallet_data << mallet_topic
  end

  def size
    @mallet_data.size
  end

  def each
    topic = Topic.new(@mallet_data, @category_vectors, @category_similarity_vectors)
    (0..@mallet_data.size-1).each do |topic_id|
      topic.id = topic_id
      yield topic
    end
  end

  def [](id)
    topic = Topic.new(@mallet_data, @category_vectors, @category_similarity_vectors)
    topic.id = id
    topic
  end
    

  def compute_category_vectors(article_gateway, confidence)
    max_topic_id = @mallet_data.size - 1
    (0..max_topic_id).each do |id|
      @category_vectors[id] = []
    end
    i = 0
    article_gateway.each do |article|
      topic_counts = TopicCounts.new
      (article.sentence_annotations || []).each do |sentence_annotation|
        (sentence_annotation.topics || []).each do |topic_id|
          topic_counts.inc(topic_id)
        end
      end
      if i == 0
        p topic_counts
      end
      i += 1
      #vector = topic_counts.normalized_vector(max_topic_id+1)
      vector = topic_counts.statistically_significant_vector(max_topic_id+1, confidence)
      vector.each_with_index do |topic_strength, id|
        @category_vectors[id] << article.id if topic_strength > 0
      end
    end
    (0..10).each do |id|
      p @category_vectors[id]
    end
  end

  def compute_matching_categories_binary_measure(category_gateway, article_count, measure)
    puts "Sorting Category Articles"
    sorted_articles = {}
    category_gateway.each do |category|
      sorted_articles[category.id] = category.articles.to_set.sort
    end
    puts "Comparing Topics"
    (0..@mallet_data.size-1).each do |topic_id|
      similarity_vector = []
      category_gateway.each do |category|
        fva = FoundVersusActualIdAnalyzer.call(@category_vectors[topic_id], sorted_articles[category.id], article_count)
        if PearsonChiSquaredTest.is_significant(article_count, sorted_articles[category.id].size,
                                              @category_vectors[topic_id].size, fva[:true_positive])

          similarity_vector[category.id] = FoundVersusActualIdAnalyzer.method(measure).call(
              fva[:false_negative],fva[:true_negative],
              fva[:true_positive],fva[:false_positive])
        else
          similarity_vector[category.id] = 0.0
        end
        # similarity_vector[category.id] = FMeasure.call(@category_vectors[topic_id], sorted_articles[category.id])
        # similarity_vector[category.id] = JaccardIndex.call(@category_vectors[topic_id],sorted_articles[category.id])
        # Using the SimpleMatchingCoefficient results in Computer Science as the top match every time
        # similarity_vector[category.id] = SimpleMatchingCoefficient.call(@category_vectors[topic_id],sorted_articles[category.id],article_count)
      end
      @category_similarity_vectors[topic_id] = similarity_vector
    end
  end

  def compute_matching_categories(category_gateway, similarity_measure, article_count)
    (0..@mallet_data.size-1).each do |topic_id|
      similarity_vector = []
      category_gateway.each do |category|
        vector = Array.new(article_count, 0)
        category.articles.each do |article_id, depth|
          vector[article_id] = 1
          #vector[article_id] = 0.85**depth
        end
        #puts category.title
        #puts category.articles.to_a.join(",")
        #puts @mallet_data[topic_id].to_s
        s = similarity_measure.call(vector, @category_vectors[topic_id])
        #puts s
        #puts "==========================="
        similarity_vector[category.id] = s
      end
      @category_similarity_vectors[topic_id] = similarity_vector
    end
  end

  def compute_matching_categories_using_ferret(category_gateway, article_count)
    field_infos = Ferret::Index::FieldInfos.new(term_vector: :no)
    field_infos.add_field(:id, store: :yes, index: :no)
    field_infos.add_field(:articles, store: :no, index: :yes)
    index = Ferret::Index::Index.new(analyzer: Ferret::Analysis::WhiteSpaceAnalyzer.new, field_infos: field_infos)
    i = 0
    category_gateway.each do |category|
      if i % 1000 == 0
        puts "Indexing Category #{i+1} of #{category_gateway.size}"
      end
      i+=1
      index << {
        id: category.id,
        articles: category.articles.map { |article_id, depth| article_id }.join(" ")
      }
    end

    (0..@mallet_data.size-1).each do |topic_id|
      topic_articles = @category_vectors[topic_id].each_with_index.map { |on_or_off, article_id| on_or_off == 1 ? article_id : nil }.compact.join(" ")
      puts topic_articles.size
      index.search_each("articles:\"#{topic_articles}\"") do |id, score|
        puts "TOPIC_ID: #{topic_id}, CATEGORY_ID: #{id}, SCORE:#{score}"
        break
      end
    end
  end

  def print_top_categories_report(category_gateway)
    topic_ids = []
    each { |topic| topic_ids << [topic.id, topic.to_enum(:sorted_similarity_categories, category_gateway).take(1)[0][0]] }
    topic_ids = topic_ids.sort_by { |id, sim| sim }
    topic_ids.each do |topic_id, sim|
      topic = self[topic_id]
      puts "#{topic.mallet_data.to_s} #{topic.category_vectors.count}"
      puts topic.to_enum(:sorted_similarity_categories, category_gateway).take(20)
           .map {|sim, category| sprintf("%.3f #{category.title} #{category.articles.count}",sim)}.join("\n")
      puts "================"
    end
  end

  def evaluate_labeler(labeler, category_gateway, out_file)
    rouge1 = RougeMetric.new(1)
    rouge2 = RougeMetric.new(2)

    CSV.open(out_file, "wb") do |csv|
      csv << %w(Topic System Reference Weight Rouge1 Rouge2 WeightedR1 WeightedR2)
      row_number = 2
      each do |topic|
        row = []
        row << topic.mallet_data.to_s
        system = labeler.call(topic)
        row << system[0..50].join(" ")[0..255]

        scores = topic.to_enum(:sorted_similarity_categories, category_gateway).take(5).map do |sim, category|
          reference = category.title
          reference_tokens = category.annotation.tokens
          row[2] = reference_tokens.join(" ")
          row[3] = sim
          row[4] = rouge1.call([reference_tokens], system)
          row[5] = rouge2.call([reference_tokens], system)
          row[6] = "=D#{row_number}*E#{row_number}"
          row[7] = "=D#{row_number}*F#{row_number}"
          csv << row
          row_number += 1
        end
        puts row_number - 1
      end

      csv << ["TOTAL","","","=SUM(D2:D#{row_number-1})","","","=SUM(G2:G#{row_number-1})/D#{row_number}","=SUM(H2:H#{row_number-1})/D#{row_number}"]
    end
  end

  def evaluate_labeler2(labeler, category_gateway, out_file)
    rouge1 = RougeMetric.new(1)
    rouge2 = RougeMetric.new(2)
    topics_score = []
    each do |topic|
      scores = topic.to_enum(:sorted_similarity_categories, category_gateway).take(3).map { |sim, category| sim }
      topics_score << [topic.id, scores.inject(0,:+).to_f/scores.count]
    end
    topics_score = topics_score.sort_by { |topic_id, score| -1 * score }

    total_r1 = 0
    total_r2 = 0
    total_r1_50 = 0
    total_r2_50 = 0
    total_50_count = 1
    File.open(out_file, "w") do |file|
      topics_score.each_with_index do |(topic_id, score), i|
        topic = self[topic_id]
        file.puts topic.mallet_data.to_s + "\n"
        references_tokens = []
        topic.to_enum(:sorted_similarity_categories, category_gateway).take(3).each do |sim, category|
          file.puts sprintf("%5.2f %s\n", sim, category.annotation.tokens.join(' '))
          references_tokens << category.annotation.tokens
        end

        if labeler.method(:call).arity == 2
          candidate_labels = labeler.call(topic, references_tokens)
        else
          candidate_labels = labeler.call(topic)
        end

        candidate_labels_tokens = candidate_labels.take(3).map(&:tokens)
        r1 = rouge1.call(references_tokens, candidate_labels_tokens)
        r2 = rouge2.call(references_tokens, candidate_labels_tokens)
        total_r1 += r1
        total_r2 += r2

        if i < topics_score.size.to_f / 2
          total_r1_50 = total_r1
          total_r2_50 = total_r2
          total_50_count = i + 1
        end

        file.puts sprintf("%10.6f %10.6f", r1, r2)
        candidate_labels.each do |candidate_label|
          file.puts candidate_label.to_s
        end

        file.puts "\n"
      end

      r1 = sprintf("Top 3 candidate R1 Average: %10.6f\n", total_r1 / topics_score.count)
      r2 = sprintf("Top 3 candidate R2 Average: %10.6f\n", total_r2 / topics_score.count)
      r3 = sprintf("Top 3 candidate R1 Average 50: %10.6f\n", total_r1_50 / total_50_count)
      r4 = sprintf("Top 3 candidate R2 Average 50: %10.6f\n", total_r2_50 / total_50_count)
      file.puts r1
      file.puts r2
      file.puts r3
      file.puts r4
      puts r1
      puts r2
      puts r3
      puts r4
    end
  end

end
