class EntireCorpusLabeler

  def initialize(article_gateway, options)
    @article_gateway = article_gateway
  end

  def call(topic)
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
      @label = tokens.join(" ")
    end

    @label
  end
end