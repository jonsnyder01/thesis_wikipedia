class TopWordLabeler

  def initialize(size)
    @size = size.to_i
  end

  def call(topic)
    topic.mallet_data.top.take(@size).map(&:token).map do |token|
      token.slice(0..0).capitalize + token.slice(1..-1)
    end.join(" ")
  end
end