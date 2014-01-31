class Importer

  def initialize(parser, article_gateway, category_gateway)
    @parser = parser
    @article_gateway = article_gateway
    @category_gateway = category_gateway
  end

  def import(file_type)
    return if ![:article_categories,
                :article_titles,
                :category_labels,
                :long_abstracts,
                :redirects_transitive,
                :skos_categories].include? file_type
    self.send(file_type)
  end

  private
  
  def article_categories
    @parser.scan([Token::Resource, Token::Url.new("http://purl.org/dc/terms/subject"), Token::Category]) do |resource, relationship, category|
      @category_gateway.find_by_slug(category.value).add_article(@article_gateway.find_by_slug(resource.value))
    end
  end

  def article_titles
    @parser.scan([Token::Resource, Token::Url.new("http://www.w3.org/2000/01/rdf-schema#label"), Token::String]) do |resource, relationship, title|
      @article_gateway.create(slug: resource.value, title: title.value)
    end
  end
  
  def category_labels
    @parser.scan([Token::Category, Token::Url.new("http://www.w3.org/2000/01/rdf-schema#label"), Token::String]) do |resource, relationship, title|
      @category_gateway.create(slug: resource.value, title: title.value)
    end
  end

  def long_abstracts
    @parser.scan([Token::Resource, Token::Ontology.new("abstract"), Token::String]) do |resource, relationship, abstract|
      @article_gateway.create(slug: resource.value, text: abstract.value)
    end
  end

  def redirects_transitive
    @parser.scan([Token::Resource, Token::Ontology.new("wikiPageRedirects"), Token::Resource]) do |resource_alias, relationship, resource|
      @article_gateway.find_by_slug(resource.value).add_alias(resource_alias.value)
    end
  end

  def skos_categories
    @parser.scan([Token::Category, Token::Skos.new("core#broader"), Token::Category]) do |child, relationship, parent|
      @category_gateway.find_by_slug(parent.value).add_child_category(@category_gateway.find_by_slug(child.value))
    end
  end
end
