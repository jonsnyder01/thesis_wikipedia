class TopNFilter

  def initialize(n)
    @n = n
    @smallest_key = nil
    @smallest_i = nil
    @keys = []
    @values = []
    @i = 0
  end

  def add(key)
    if @i % 1000 == 0
      puts "TopNFilter: " + @i.to_s
    end
    @i += 1

    if @smallest_key.nil?
      @keys << key
      @values << yield
      if @values.size == @n
        @smallest_key = @keys.min
        @smallest_i = @keys.rindex(@smallest_key)
      end
    elsif key > @smallest_key
      value = yield
      if !@values.include?(value)
        @keys[@smallest_i] = key
        @values[@smallest_i] = yield
        @smallest_key = @keys.min
        @smallest_i = @keys.rindex(@smallest_key)
      end
    end
  end

  def would_be_added?(key)
    @smallest_key.nil? || key > @smallest_key
  end

  def top
    Enumerator.new do |y|
      @keys.zip(@values).sort_by {|k, v| -1 * k}.each {|k, v| y << [k, v]}
    end
  end

end