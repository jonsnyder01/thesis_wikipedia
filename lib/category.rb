class Category

  def initialize(gateway, properties)
    @gateway = gateway
    @id = properties[:id]
    @title = properties[:title]
    @slug = properties[:slug]
    @children = properties[:children]
    @has_parent = properties[:has_parent]
    @articles = properties[:articles]
    @transitive_articles = properties[:transitive_articles]
    
    raise ArgumentError.new("you must pass values for :id or :slug") unless @id || @slug
  end

  def id
    @id ||= @gateway.get_id_by_slug(@slug)
  end

  def save
    @id = @gateway.save({id: id, slug: @slug, children: @children, title: @title, has_parent: @has_parent, articles: @articles, transitive_articles: @transitive_articles})
    nil
  end

  def title
    @title ||= @gateway.get_title_by_id(id)
  end

  def article_count
    transitive_articles.size
  end
  
  def article_titles(article_gateway)
    transitive_articles.map do |article_id|
      article_gateway.get_title_by_id(article_id)
    end
  end

  def add_child_category(category)
    child_categories << category
    nil
  end

  def add_article(article)
    article_ids << article.id
    nil
  end

  def calculate_transitive_articles
    transitive_articles
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

  def child_categories
    @child_categories ||= @gateway.get_child_categories_by_id(id)
  end

  def article_ids
    @article_ids ||= @gateway.get_article_ids_by_id(id)
  end

  def has_parent?
    @has_parent ||= @gateway.get_has_parent_by_id(id)
  end

  def transitive_articles
    @transitive_articles ||= @gateway.get_transitive_article_ids_by_id(id)
    return @transitive_articles if @transitive_articles
    return articles if @calculating_transitive_articles

    @transitive_articles = @gateway.get_new_set(@id).merge(article_ids)
    @calculating_transitive_articles = true
    child_categories.each do |child_category|
      @transitive_articles.merge child_category.transitive_articles
    end
    @calculating_transitive_articles = false
    @transitive_articles
  end

end
