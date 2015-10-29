class ObjectStore
  
  def initialize(marshal_helper, filename, default_value=nil, &block)
    @marshal_helper = marshal_helper
    @filename = filename
    @default_value = default_value
    @default_block = block
  end

  def [](id)
    objects_by_id[id] || (@default_block ? @default_block.call : @default_value)
  end

  def []=(id,value)
    objects_by_id[id] = value
  end

  def nil?(id)
    objects_by_id[id].nil?
  end

  def <<(value)
    objects_by_id << value
  end
  
  def size
    objects_by_id.size
  end
  
  def flush
    if @objects_by_id
      @marshal_helper.dump(@objects_by_id, @filename)
    end
  end

  def print
    objects_by_id.each_with_index do |obj, i|
      puts obj.to_s
    end
  end

  def clear
    @objects_by_id = []
  end

  private

  def objects_by_id
    @objects_by_id ||= @marshal_helper.load(@filename) || []
  end
end
  

