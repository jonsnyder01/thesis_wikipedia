class ObjectStore
  
  def initialize(marshal_helper, filename, default_value=nil, &block)
    @marshal_helper = marshal_helper
    @filename = filename
    @is_dirty = false
    @default_value = default_value
    @default_block = block
  end

  def [](id)
    objects_by_id[id] || (@default_block ? @default_block.call : @default_value)
  end

  def []=(id,value)
    @is_dirty = true
    objects_by_id[id] = value
  end

  def nil?(id)
    objects_by_id[id].nil?
  end

  def <<(value)
    @is_dirty = true
    objects_by_id << value
  end
  
  def size
    objects_by_id.size
  end

  def build_subset(subset_object_store, new_ids_by_old_id)
    new_ids_by_old_id.each do |old_id, new_id|
      next if self.nil?(old_id)
      subset_object_store[new_id] = self[old_id].dup
    end
  end
  
  def flush
    if @is_dirty
      @marshal_helper.dump(@objects_by_id, @filename)
    end
  end

  private

  def objects_by_id
    @objects_by_id ||= @marshal_helper.load(@filename) || []
  end
end
  
