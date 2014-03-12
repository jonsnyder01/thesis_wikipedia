require 'topic_counts'
require 'rouge_metric'

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
      @category_similarity_vectors[@id].each_with_index.sort_by { |sim, id| sim.nan? ? 0 : -sim }.each do |sim, id|
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

  def compute_category_vectors(article_gateway)
    max_topic_id = @mallet_data.size - 1
    (0..max_topic_id).each do |id|
      @category_vectors[id] = []
    end
    article_gateway.each do |article|
      topic_counts = TopicCounts.new
      (article.sentence_annotations || []).each do |sentence_annotation|
        (sentence_annotation.topics || []).each do |topic_id|
          topic_counts.inc(topic_id)
        end
      end
      vector = topic_counts.normalized_vector(max_topic_id+1)
      vector.each_with_index do |topic_strength, id|
        @category_vectors[id] << topic_strength
      end
    end
  end

  def compute_matching_categories(category_gateway, similarity_measure, article_count)
    (0..@mallet_data.size-1).each do |topic_id|
      similarity_vector = []
      category_gateway.each do |category|
        vector = Array.new(article_count, 0)
        category.articles.each do |article_id, depth|
          vector[article_id] = 0.85**depth
        end
        #puts category.title
        #puts category.articles.to_a.join(",")
        #puts @mallet_data[topic_id].to_s
        s = similarity_measure.call(vector, @category_vectors[topic_id])
        #puts s
        #puts "==========================="
        similarity_vector[category.id] = s
      end
      @category_similarity_vectors << similarity_vector
    end
  end

  def print_top_categories_report(category_gateway)
    each do |topic|
      puts topic.mallet_data.to_s
      puts topic.to_enum(:sorted_similarity_categories, category_gateway).take(5)
           .map {|sim, category| sprintf("%.3f #{category.title}",sim)}.join("\n")
      puts "================"
    end
  end

  def evaluate_labeler(labeler, category_gateway)
    rouge1 = RougeMetric.new(1)
    rouge2 = RougeMetric.new(2)

    CSV do |csv|
      csv << %w(Topic System Reference Weight Rouge1 Rouge2 WeightedR1 WeightedR2)
      row_number = 2
      each do |topic|
        row = []
        row << topic.mallet_data.to_s
        system = labeler.call(topic)
        row << system[0..50].join(" ")[0..100]

        scores = topic.to_enum(:sorted_similarity_categories, category_gateway).take(5).map do |sim, category|
          reference = category.title
          reference_tokens = reference.split(" ").map(&:downcase)
          row[2] = reference
          row[3] = sim
          row[4] = rouge1.call(reference_tokens, system)
          row[5] = rouge2.call(reference_tokens, system)
          row[6] = "=D#{row_number}*E#{row_number}"
          row[7] = "=D#{row_number}*F#{row_number}"
          csv << row
          row_number += 1
        end
      end

      csv << ["TOTAL","","","=SUM(D2:D#{row_number-1})","","","=SUM(G2:G#{row_number-1})/D#{row_number}","=SUM(H2:H#{row_number-1})/D#{row_number}"]
    end
  end
end
