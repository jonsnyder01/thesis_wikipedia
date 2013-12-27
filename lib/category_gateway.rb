require 'not_found'
require 'slug_store'
require 'string_store'
require 'set_store'

class CategoryGateway

  class Category

    def initialize(id, articles, child_category_sets)
      @id = id
      @articles = articles
      @child_category_sets = child_category_sets
    end
    
    def id
      @id
    end

    def add_article(article)
      @articles[@id] = (@articles[@id] << article.id)
    end

    def add_child_category(category)
      @child_category_sets[@id] = (@child_category_sets[@id] << category.id)
    end

  end
  
  def initialize(slugs, titles, article_sets, child_category_sets)
    @slugs = slugs
    @titles = titles
    @article_sets = article_sets
    @child_category_sets = child_category_sets
  end

  def create(properties)
    raise ArgumentError.new("You must include a slug parameter") unless properties[:slug]

    id = @slugs.create(properties[:slug])
    @titles[id] = properties[:title] if properties[:title]
    nil
  end
  
  def find_by_slug(slug)
    id = @slugs.find_id_by_slug(slug)
    Category.new(id, @article_sets, @child_category_sets)
  end

  def calculate_transitive_articles(store, category_slug=nil, depth=10)
    if category_slug
      id = @slugs.find_id_by_slug(category_slug)
      raise ArgumentError.new("Could not find #{category_slug}") unless id
      store[id] = calculate_transitive_articles_for_category(id, store, depth)      
    else
      @slugs.each_id do |id|
        store[id] = calculate_transitive_articles_for_category(id, store)
      end
    end
  end

  private

  def calculate_transitive_articles_for_category(id, store, depth)
    return store[id] unless store.nil?(id)

    a = store[id] = store[id].merge(@article_sets[id])
    @child_category_sets[id].each do |category_id|
      a.merge(calculate_transitive_articles_for_category(category_id, store, depth-1))
    end if depth > 0
    a
  end
  
end

