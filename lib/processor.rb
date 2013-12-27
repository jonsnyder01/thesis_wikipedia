
class CalculateTransitiveCategoriesCommand

  def initialize(category_gateway, store)
    @category_gateway = category_gateway
    @store = store
  end

  def calc
    @category_gateway.calculate_transitive_categories(@store)
  end
end
