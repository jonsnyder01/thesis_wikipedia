require 'json'

class SimpleArticleGateway

  class Article
    def initialize(titles, texts, annotations)
      @titles = titles
      @texts = texts
      @annotations = annotations
    end

    def id=(value)
      @id = value
    end

    def id
      @id
    end

    def title
      @titles[@id]
    end

    def text
      @texts[@id]
    end

    def sentence_annotations
      @annotations[@id]
    end
  end
  
  def initialize(titles,texts,annotations)
    @size = [titles.size,texts.size].min
    @titles = titles
    @texts = texts
    @annotations = annotations
  end

  def create(title, text)
    @titles << title
    @texts << text
    @size += 1
  end

  def annotate_all(annotator)
    p "Annotate ALL"
    p @texts.size
    (0..@texts.size-1).each do |id|
      next if @texts.nil?(id)
      annotations = annotator.parse(@texts[id])
      @annotations[id] = annotations
    end
  end
  
  def subset(other, article_ids)
    article_ids.each do |id|
      other.create(@titles[id], @texts[id])
    end
  end

  def write_pipeline_file(file)
    (0..@size-1).each do |id|
      title = @titles[id]
      text = @texts[id]
      next unless title && text
      file.puts JSON.dump({id: id, title: title, text: text})
    end
  end

  def size
    @size
  end

  def each
    article = Article.new(@titles, @texts, @annotations)
    (0..@size-1).each do |id|
      article.id = id
      yield article
    end
  end      
  
end
