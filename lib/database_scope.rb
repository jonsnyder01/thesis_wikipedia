
require 'article_gateway'
require 'simple_article_gateway'
require 'category_gateway'
require 'simple_category_gateway'
require 'slug_store'
require 'object_store'
require 'set'

class DatabaseScope

  def initialize(marshal_helper)
    @marshal_helper = marshal_helper
  end

  def article_gateway
    @article_gateway ||= ArticleGateway.new(article_slugs,article_titles,article_texts)
  end

  def simple_article_gateway
    @simple_article_gateway ||= SimpleArticleGateway.new(article_titles,article_texts)
  end

  def logging_simple_article_gateway
    @logging_simple_article_gateway ||= SimpleArticleGateway.new(logging_article_titles,article_texts)
  end

  def article_slugs
    @article_slugs ||= SlugStore.new(@marshal_helper, 'article_slugs')
  end

  def article_titles
    @article_titles ||= ObjectStore.new(@marshal_helper, 'article_titles')
  end

  def logging_article_titles
    @logging_article_titles ||= LoggingObjectStore.new(article_titles, STDERR)
  end

  def article_texts
    @article_texts ||= ObjectStore.new(@marshal_helper, 'article_texts')
  end

  def category_gateway
    @category_gateway ||= CategoryGateway.new(category_slugs,category_titles,category_article_sets,category_child_category_sets)
  end

  def simple_category_gateway
    @simple_category_gateway ||= SimpleCategoryGateway.new(category_titles,category_article_sets)
  end

  def logging_simple_category_gateway
    @logging_simple_category_gateway ||= SimpleCategoryGateway.new(logging_category_titles,category_article_sets)
  end

  def category_slugs
    @category_slugs ||= SlugStore.new(@marshal_helper, 'category_slugs')
  end

  def category_titles
    @category_titles ||= ObjectStore.new(@marshal_helper, 'category_titles')
  end

  def logging_category_titles
    @logging_category_titles ||= LoggingObjectStore.new(category_titles, STDERR)
  end

  def category_article_sets
    @category_article_sets ||= ObjectStore.new(@marshal_helper, 'category_article_sets') { Set.new }
  end

  def logging_category_article_sets
    @logging_category_article_sets ||= LoggingObjectStore.new(category_article_sets, STDERR)
  end

  def category_child_category_sets
    @category_child_category_sets ||= ObjectStore.new(@marshal_helper, "category_child_category_sets") { Set.new }
  end
end

  
