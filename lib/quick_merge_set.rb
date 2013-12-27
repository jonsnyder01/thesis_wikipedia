class QuickMergeSet
  include Enumerable

  def initialize(ordered_array)
    @data = ordered_array
  end

  def merge(other)
    result = []
    e1 = self.to_enum
    e2 = other.to_enum
    loop do
      difference = e1.peek - e2.peek
      if difference == 0
        result << e1.next
        e2.next
      elsif difference < 0
        result << e1.next
      else
        result << e2.next
      end
    end
    loop do
      result << e1.next
    end
    loop do
      result << e2.next
    end
    QuickMergeSet.new(result)
  end

  def each(&block)
    @data.each(&block)
  end
  
end
