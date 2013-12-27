class Article
  def initialize(gateway, properties)
    @gateway = gateway

    @id = properties[:id]
    @slug = properties[:slug]
    @title = properties[:title]
    @long_abstract = properties[:long_abstract]
  end

  def save
    @id = @gateway.save({id: id, slug: @slug, title: @title, long_abstract: @long_abstract, aliases: @aliases})
    nil
  end

  def id
    @id ||= @gateway.get_id_by_slug(@slug)
  end

  def add_alias(slug)
    (@aliases ||= []) << slug
    nil
  end

  def hash
    (id || @slug).hash
  end

  def eql?(other)
    if id.nil? && other.id.nil?
      slug == other.slug
    else
      id == other.id
    end
  end

  def ==(other)
    eql?(other)
  end

  protected

  def slug
    @slug
  end  
end
  
