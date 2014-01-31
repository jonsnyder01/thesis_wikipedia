require 'topic_counts'

class TopicGateway

  def initialize(mallet_data, category_vectors, category_similarity_vectors)
    @mallet_data = mallet_data
    @category_vectors = category_vectors
    @category_similarity_vectors = category_similarity_vectors
  end

  def create(mallet_topic)
    @mallet_data << mallet_topic
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
    (0..@mallet_data.size-1).each do |topic_id|
      puts @mallet_data[topic_id].to_s
      puts @category_similarity_vectors[topic_id].each_with_index.sort_by { |sim, id| sim.nan? ? 0 : -sim }.take(5)
           .map {|sim, id| sprintf("%.3f #{category_gateway[id].title}",sim)}.join("\n")
      puts "================"
    end
  end
end
