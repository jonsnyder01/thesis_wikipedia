class FixedCategoryGateway

  class Category
    def initialize(id,titles,article_sets)
      @id = id
      @titles = titles
      @article_sets = article_sets
    end

    def title
      @title ||= @titles[@id]
    end

    def articles
      @articles ||= @article_sets[@id]
    end
  end

  def [](id)
    Category.new(titles[id],articles[id])
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
    article_id_map = Hash[@article_sets[id].each_with_index.to_a]
    
    (0..@size-1).each do |old_category_id|
      article_ids = (@article_sets[id] & @article_sets[category_id]).map do |old_article_id|
        article_id_map[old_artile_id]
      end
      if new_article_set.size >= minimum_category_size
        other.create(
          title: @titles[old_category_id],
          article_set: Set.new(article_ids)
          )
      end
    end
  end

end
