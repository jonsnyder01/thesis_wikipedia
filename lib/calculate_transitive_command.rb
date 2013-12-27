
class CalculateTransitiveCommand

  def initialize(category_gateway, store)
    @category_gateway = category_gateway
    @store = store
  end

  def run(category_slug=nil)
    @category_gateway.calculate_transitive_articles(@store, category_slug)
  end
end