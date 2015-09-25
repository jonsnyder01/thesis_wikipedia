require 'json'
require 'similarity_matrix'

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
    puts "Annotate all article text (#{@texts.size})"
    texts = Enumerator.new do |y|
      (0..@texts.size-1).each do |id|
        next if @texts.nil?(id)
        y << [id, @texts[id]]
      end
    end
    annotator.parse(texts).each do |id, annotation|
      @annotations[id] = annotation
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

  def print_tokenized
    each do |article|
      article.sentence_annotations.each do |annotation|
        puts annotation.tokens.join(" ")
      end
    end
  end

  def print_topics
    i = 0
    each do |article|
      article.sentence_annotations.each do |annotation|
        i += 1
        puts i.to_s + " " + (annotation.topics || []).join(" ")
      end
    end
  end

  def print_sentence_matrix(output_file, from, to)
    i = 0
    vectors = []
    each do |article|
      article.sentence_annotations.each do |annotation|
        vectors << SimilarityMatrix::Vector.new(i, annotation.topic_counts)
        i += 1
      end
    end
    matrix = SimilarityMatrix.new(vectors)
    matrix.calculate(output_file, from, to)
  end
end
