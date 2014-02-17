class SubsetCommand

  def initialize(
      input_article_gateway,
      input_category_gateway,
      output_article_gateway,
      output_category_gateway
      )
    @input_article_gateway = input_article_gateway
    @input_category_gateway = input_category_gateway
    @output_article_gateway = output_article_gateway
    @output_category_gateway = output_category_gateway
  end

  def run(category_id, minimum_category_size=100)
    @input_category_gateway.subset(@output_category_gateway, category_id, minimum_category_size)
    article_ids = @input_category_gateway[category_id].articles.to_set
    @input_article_gateway.subset(@output_article_gateway, article_ids)
  end
     
end
