class SparseVector
  include Enumerable

  def initialize
    @vector = {}
  end

  def merge(other)
    case other
      when Set
        other.each do |id|
          @vector[id] = 1
        end
      when SparseVector
        other.each do |id, depth|
          @vector[id] = depth + 1
        end
    end
  end

  def [](id)
    @vector[id]
  end

  def []=(id, value)
    @vector[id] = value if value
  end

  def size
    @vector.size
  end

  def to_set
    @vector.keys
  end

  def each(&block)
    @vector.each(&block)
  end

end