class LabelDiscriminator

  def initialize(labeler, topic_ids, factor)
    @labeler = labeler
    @topic_ids = topic_ids
    @scaled_factor = factor.to_f / (@topic_ids.count - 1)

    process
  end

  def top_n_labels(topic, n)

    top_labels = labeler.top_n_labels(topic, n)
    top_labels.map do |label|
      new_score = label.score
      topic_ids.each do |other_topic|
        next if topic == other_topic
        new_score -= labeler.score(other_topic) / @scaled_factor
      end
      WrappedCandidateLabel(new_score, label)
    end.sort_by { |label| -1 * label.score }
  end

end