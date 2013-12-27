class TupleLogger

  def initialize(file,size)
    @file = file
    @tuple_counts = Hash.new { 0 }
    @tuples = {}
    @size = size
  end

  def log(prototype, tuple)
    @tuple_counts[prototype] += 1
    if @tuple_counts[prototype] <= @size
      @tuples[prototype] ||= []
      @tuples[prototype] << tuple
    end
  end

  def close
    @tuples.each do |prototype, tuples|
      @file.puts("#{prototype.to_s}: #{@tuple_counts[prototype]}")
      tuples.each do |tuple|
        @file.puts("#{tuple.to_s}")
      end
      @file.puts ""
    end
  end
end
