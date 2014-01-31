class MalletTopic
  attr_reader :alpha, :tokens, :title, :top

  def initialize(alpha, tokens, title, top)
    @alpha = alpha
    @tokens = tokens
    @title = title
    @top = top
  end

  class Top
    attr_reader :count, :token

    def initialize(count, token)
      @count = count
      @token = token
    end
  end

  def to_s
    self.top.take(10).map(&:token).join(',')
  end
end
