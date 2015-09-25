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
      @article_gateway.each do |article|
        article.sentence_annotations.each do |sentence|
          sentence.tokens.each do |token|
            tokens << token
          end
          tokens << "."
        end
      end
      @label = tokens
    end

    @label
  end
end