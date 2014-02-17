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
        category.articles.each do |article_id|
          vector[article_id] = 1
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
    each do |topic|
      puts topic.mallet_data.to_s
      system = labeler.call(topic)
      puts system
      system_tokens = system.split(" ").map(&:downcase)
      scores = topic.to_enum(:sorted_similarity_categories, category_gateway).take(5).map do |sim, category|
        reference = category.title.value
        reference_tokens = reference.split(" ").map(&:downcase)
        rouge1_score = rouge1.call(reference_tokens, system_tokens)
        rouge2_score = rouge2.call(reference_tokens, system_tokens)
        [sim, rouge1_score, rouge2_score, reference]
      end

      r1 =      scores.map { |s, r1, r2, t| s * r1 }.inject(:+)
      r2 =      scores.map { |s, r1, r2, t| s * r2 }.inject(:+)
      weights = scores.map { |s, r1, r2, t| s }.inject(:+)
      scores.each do |scores|
        puts sprintf("%.3f %.3f %.3f %s", *scores)
      end
      puts sprintf("      %.3f %.3f", r1 / weights, r2 / weights)
      puts "=============================="
    end
  end
end
