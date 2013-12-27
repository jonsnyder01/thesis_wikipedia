class SetStore
  include Enumerable

  def initialize(marshal_helper, filename)
    @marshal_helper = marshal_helper
    @filename = filename
    @is_dirty = false
  end

  def add(id, new_id)
    @is_dirty = true
    sets_by_id[id] = (sets_by_id[id] || Set.new) << new_id
  end

  def merge(id, new_ids)
    @is_dirty = true
    sets_by_id[id] = (sets_by_id[id] || Set.new).merge(new_ids)
  end

  def [](id)
    (sets_by_id[id] || []).to_a
  end

  def <<(value)
    @is_dirty = true
    sets_by_id << value
  end

  def nil?(id)
    sets_by_id[id].nil?
  end

  def flush
    if @is_dirty
      @marshal_helper.dump(@sets_by_id, @filename)
    end
  end

  protected

  def sets_by_id
    @sets_by_id ||= @marshal_helper.load(@filename) || []
  end    
  
end

