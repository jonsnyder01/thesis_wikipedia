class StringStore
  
  def initialize(marshal_helper, filename)
    @marshal_helper = marshal_helper
    @filename = filename
    @is_dirty = false
  end

  def [](id)
    strings_by_id[id]
  end

  def []=(id,value)
    @is_dirty = true
    strings_by_id[id] = value
  end

  def <<(value)
    @is_dirty = true
    strings_by_id << value
  end

  def flush
    if @is_dirty
      @marshal_helper.dump(@strings_by_id, @filename)
    end
  end

  private

  def strings_by_id
    @strings_by_id ||= @marshal_helper.load(@filename) || []
  end
end
  

