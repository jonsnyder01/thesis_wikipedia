module FoundVersusActualIdAnalyzer

  def self.call(found, actual, size)
    false_negative = 0
    true_negative = size
    true_positive = 0
    false_positive = 0
    found_index = 0
    actual_index = 0
    while found_index < found.size && actual_index < actual.size
      found_id = found[found_index]
      actual_id = actual[actual_index]
      if found_id == actual_id
        found_index += 1
        actual_index += 1
        true_positive += 1
      elsif found_id > actual_id
        actual_index += 1
        false_negative += 1
      else
        found_index += 1
        false_positive += 1
      end
      true_negative -= 1
    end

    if found_index == found.size
      false_negative += actual.size - actual_index
      true_negative -= actual.size - actual_index
    else
      false_positive += found.size - found_index
      true_negative -= found.size - found_index
    end


    {false_negative: false_negative, true_negative: true_negative,
     true_positive: true_positive, false_positive: false_positive}
  end

  def self.f2(false_negative, true_negative, true_positive, false_positive)
    return 0 if true_positive == 0
    (5 * true_positive).to_f / (5 * true_positive + 4 * false_negative + false_positive)
  end

  def self.f1(false_negative, true_negative, true_positive, false_positive)
    return 0 if true_positive == 0
    (2 * true_positive).to_f / (2 * true_positive + false_negative + false_positive)
  end

  def self.f05(false_negative, true_negative, true_positive, false_positive)
    return 0 if true_positive == 0
    (1.25 * true_positive).to_f / (1.25 * true_positive + 0.25 * false_negative + false_positive)
  end

  def self.jaccard(false_negative, true_negative, true_positive, false_positive)
    return 0 if true_positive == 0
    true_positive.to_f / (true_positive + false_negative + false_positive)
  end

  def self.accuracy(false_negative, true_negative, true_positive, false_positive)
    return 0 if (true_positive + true_negative) == 0
    (true_positive + true_negative).to_f / (false_negative + true_negative + true_positive + false_positive)
  end
end