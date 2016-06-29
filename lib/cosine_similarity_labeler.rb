require 'incremental_cosine_similarity'
require 'top_n_filter'
require 'counting_word_trie'
require 'candidate_label'

class CosineSimilarityLabeler

  def initialize(counting_phrase, topic_vectors, boost_function, size)
    @counting_phrase = counting_phrase
    @topic_vectors = topic_vectors
    @boost_function = boost_function
    @size = size
  end

  def call(topic)
    top = TopNFilter.new(@size)
    sorted_topic_vector = @topic_vectors[topic.id].sort_by { |word, score| -1 * score }
    recursiveProcessor(
        IncrementalCosineSimilarity.new,
        @counting_phrase.trie,
        sorted_topic_vector,
        top,
        @counting_phrase.depth
    )
    top.top.map do |score, tokens|
      CandidateLabel.new(tokens, sprintf("%10.4f %s", score, tokens.join(" ")))
    end
  end

  def recursiveProcessor(similarity, trie, sorted_topic_vector, top, depth)
    return if depth == 0
    sorted_topic_vector.each do |word, score|
      next unless trie.hash.has_key? word
      similarity.add(word, score)
      phrase_score = similarity.similarity
      boost = @boost_function.call(trie.hash[word].count)
      if trie.terminal
        top.add(phrase_score * boost) { similarity.tokens }
      end
      best_possible_score = boost * (phrase_score * Math.sqrt(similarity.size) + (depth - 1) * sorted_topic_vector[0][1]) /
          Math.sqrt(depth+similarity.size - 1)
      if top.would_be_added?(best_possible_score)
        recursiveProcessor(similarity, trie.hash[word], sorted_topic_vector, top, depth - 1)
      end
      similarity.remove(word, score)
    end

  end

=begin
    trie.hash.each do |word, sub_trie|
      similarity.add(word, topic_vector[word])
      top.add(similarity.similarity * Math.log(trie.count + 1)) { similarity.tokens }
      recursiveProcessor(similarity, sub_trie, topic_vector, top)
      similarity.remove(word, topic_vector[word])
    end
  end

  def old_call(topic)
    top = TopNFilter.new(@size)
    @article_gateway.each do |article|
      article.sentence_annotations.each do |sentence_annotation|
        incremental_similarities = []
        sentence_annotation.tokens.each do |token|
          incremental_similarities << IncrementalCosineSimilarity.new
          magnitude = @topic_vectors[topic.id][token]
          incremental_similarities.each do |it|
            it.add(token, magnitude)
            top.add(it.similarity) { it.tokens }
          end
        end
      end
    end
    top.top.map { |score, tokens| tokens.join(' ') }.join(' - ').split(' ')
  end

  def preprocess
    @trie = CountingWordTrie.new
    @article_gateway.each do |article|
      article.sentence_annotations.each do |sentence_annotation|
        @trie.add_all_continuous_subsets_of_length(sentence_annotation.tokens, 5)
      end
    end
    puts @trie.count
  end
=end

end

