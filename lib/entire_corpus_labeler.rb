class EntireCorpusLabeler

  def initialize(article_gateway, options={})
    @article_gateway = article_gateway
  end

  def call(topic)
=begin
    words = Set.new
    bigrams = Set.new
    categories.each do |category|
      annotation.tokens.each_ngram(2) do |ngram|
        bigrams << ngram.join(" ")
      end
    end
    @article_gateway.each do |article|
=end
    label
  end

  private

  def label
    if !@label
      tokens = []
      i = 0
      @article_gateway.each do |article|
        article.sentence_annotations do |sentence|
          sentence.tokens.each do |token|
            tokens << token
          end
          tokens << "."
        end
        puts i if i % 1000 == 0
        i+=1
      end
      @label = tokens
    end

    @label
  end
end