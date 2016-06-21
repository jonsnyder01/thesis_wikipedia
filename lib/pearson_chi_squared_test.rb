module PearsonChiSquaredTest
  def self.is_significant(article_count, category_count, topic_count, true_positive)
    (((topic_count*category_count)/article_count - true_positive)**2).to_f / true_positive > 6.64
  end

  def self.is_significant2(article_count, category_count, topic_count, true_positive)
    expected = (topic_count*category_count)/article_count
    expected < true_positive && (((true_positive - expected)**2).to_f / expected > 6.64)
  end
end