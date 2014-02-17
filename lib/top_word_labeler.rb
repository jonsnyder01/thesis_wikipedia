class TopWordLabeler

  def initialize(article_gateway, options={})
    @size = options[:size].to_i || 5
  end

  def call(topic)
    topic.mallet_data.top.take(@size).map(&:token)

    #token.slice(0..0).capitalize + token.slice(1..-1)
  end
end