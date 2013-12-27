require 'not_found'

class SlugStore

  def initialize(marshal_helper, location)
    @marshal_helper = marshal_helper
    @location = location
    @ids_by_slug = nil
    @count = nil
  end

  def create(slug)
    id = ids_by_slug[slug] 
    return id if id

    @is_dirty = true
    id = count
    @count += 1
    ids_by_slug[slug] = id
  end

  def create_alias(id, alias_slug)
    @is_dirty = true
    ids_by_slug[alias_slug] = id
    nil
  end

  def find_id_by_slug(slug)
    id = ids_by_slug[slug]
    return id if id
    
    raise NotFound.new "Could not find '#{slug}'"
  end

  def flush
    if @is_dirty
      @marshal_helper.dump([@ids_by_slug,@count], @location)
      @is_dirty = false
    end
  end

  def each_id
    (0..count-1).each do |i|
      yield i
    end
  end

  private

  def ids_by_slug
    return @ids_by_slug if @ids_by_slug
    load
    @ids_by_slug
  end

  def count
    return @count if @count
    load
    @count
  end

  def load
    @ids_by_slug, @count = @marshal_helper.load(@location) || [{},0]
  end
end


