require 'set'

class AllWordLabeler

  def initialize(article_gateway, options={})
    @article_gateway = article_gateway
  end

  def call(topic)
    all_word_label
  end

  def all_word_label
    @all_word_label ||= begin
      all_words = Set.new
      @article_gateway.each do |article|
        article.sentence_annotations.each do |sentence_annotation|
          sentence_annotation.tokens.each do |token|
            all_words << token
          end
        end
      end
      all_words.to_a.sort
    end
  end
end