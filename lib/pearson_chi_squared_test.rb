module PearsonChiSquaredTest
  def self.is_significant(article_count, category_count, topic_count, true_positive)
    (((topic_count*category_count)/article_count - true_positive)**2).to_f / true_positive > 6.64
  end
end