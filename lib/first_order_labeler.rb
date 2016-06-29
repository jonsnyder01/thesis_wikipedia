require 'label_context_model'
require 'top_n_filter'
require 'candidate_label'
require 'significant_labels'

class FirstOrderLabeler
  def initialize(article_gateway, counting_phrase, topic_vectors, size)
    @article_gateway = article_gateway
    @topic_vectors = topic_vectors
    @size = size

    process(counting_phrase)
  end

  def process(counting_phrase)
    @parred_phrases = CountingWordTrie.new
    # par down the number of labels
    significant_labels = SignificantLabels.new(counting_phrase, @article_gateway)
    significant_labels.call(1000).each do |score, label|
      @parred_phrases.add_phrase(label)
    end

    label_context_model = LabelContextModel.new
    @article_gateway.each do |article|
      article.sentence_annotations.each do |sentence_annotation|
        phrases = @parred_phrases.find_phrases_in_sentence(sentence_annotation.tokens)
        label_context_model.add_sentence_with_labels(sentence_annotation.tokens, phrases)
      end
    end

    @label_dists = label_context_model.compute_label_distributions()
  end


  def call(topic)
    top = TopNFilter.new(@size)
    recursive_processor(@topic_vectors[topic.id], nil, top, @parred_phrases)

    top.top.map do |score, tokens|
      CandidateLabel.new(tokens.split(' '), sprintf("%10.4f %s", score, tokens))
    end
  end

  def recursive_processor(topic_dist, label, top, trie)
    trie.hash.each do |word, sub_trie|
      sub_label = label.nil? ? word : label + " " + word
      if sub_trie.terminal && @label_dists.has_key?(sub_label)
        label_dist = @label_dists[sub_label]
        score = topic_dist.reduce(0) do |sum, (word, topic_prob)|
          if label_dist.has_key?(word)
            sum + topic_prob * label_dist[word]
          else
            sum
          end
        end
        top.add(score) { sub_label }
      end
      recursive_processor(topic_dist, sub_label, top, sub_trie)
    end
  end


end