class SimpleCategoryGateway

  class Category
    attr_accessor :id

    def initialize(titles,article_sets)
      @titles = titles
      @article_sets = article_sets
    end

    def title
      @titles[id]
    end

    def articles
      @article_sets[id]
    end
  end

  def [](id)
    c = Category.new(@titles, @article_sets)
    c.id = id
    c
  end

  def initialize(titles, article_sets)
    @size = [titles.size,article_sets.size].min
    @titles = titles
    @article_sets = article_sets
  end

  def create(properties)
    @titles << properties[:title]
    @article_sets << properties[:article_set]
    @size += 1
  end
  
  def subset(other, id, minimum_category_size=100)
    article_id_map = Hash[@article_sets[id].to_set.each_with_index.to_a]

    (0..@size-1).each do |old_category_id|
      new_article_vector = SparseVector.new
      @article_sets[old_category_id].each do |old_article_id, depth|
        new_article_vector[article_id_map[old_article_id]] = depth if article_id_map.has_key?(old_article_id)
      end
      if new_article_vector.size >= minimum_category_size
        other.create(
          title: @titles[old_category_id],
          article_set: new_article_vector
          )
      end
    end
  end

  def write_pipeline_file(file)
    (0..@size-1).each do |id|
      title = @titles[id]
      article_set = @article_sets[id]
      next unless title && article_set
      file.puts JSON.dump({id: id, title: title, articles: article_set.to_a})
    end
  end

  def each
    category = Category.new(@titles, @article_sets)
    (0..@size-1).each do |id|
      category.id = id
      yield category
    end
  end

end
