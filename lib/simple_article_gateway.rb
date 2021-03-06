require 'json'
require 'similarity_matrix'

class SimpleArticleGateway

  class Article
    def initialize(titles, texts, annotations, phrases)
      @titles = titles
      @texts = texts
      @annotations = annotations
      @phrases = phrases
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
      @annotations[@id] || []
    end

    def phrases
      @phrases[@id] || []
    end
  end
  
  def initialize(titles,texts,annotations,phrases)
    @size = [titles.size,texts.size].min
    @titles = titles
    @texts = texts
    @annotations = annotations
    @phrases = phrases
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

  def extract_phrases(phrase_extractor)
    puts "Extracting phrases"
    texts = Enumerator.new do |y|
      (0..@annotations.size-1).each do |id|
        next if @annotations.nil?(id)
        y << [id, @annotations[id]]
      end
    end
    phrase_extractor.run(texts).each do |id, phrases|
      @phrases[id] = phrases
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
    article = Article.new(@titles, @texts, @annotations, @phrases)
    (0..@size-1).each do |id|
      article.id = id
      yield article
      p id if id % 1000 == 0
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
