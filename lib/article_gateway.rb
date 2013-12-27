require 'json'
require 'not_found'
require 'slug_store'
require 'object_store'

class ArticleGateway

  class Article
    def initialize(id, slugs)
      @id = id
      @slugs = slugs
    end

    def id
      @id
    end
    
    def add_alias(slug)
      @slugs.create_alias(@id, slug)
    end
  end
  
  def initialize(slugs, titles, texts)
    @slugs = slugs
    @titles = titles
    @texts = texts
  end

  def create(properties)
    raise ArgumentError.new("You must include a slug parameter") unless properties[:slug]
    
    id = @slugs.create(properties[:slug])
    @titles[id] = properties[:title] if properties[:title]
    @texts[id] = properties[:text] if properties[:text]
  end
  
  def find_by_slug(slug)
    id = @slugs.find_id_by_slug(slug)
    Article.new(id, @slugs)
  end

end
