class Products::List::GetSerializedProducts
  def initialize(filter_and_sort_params)
    @filter_and_sort_params = filter_and_sort_params
  end

  def exec
    products_filtered_and_sorted = Product.ransack(@filter_and_sort_params).result
    upload_file_ids = products_filtered_and_sorted.map(&:upload_file_id)

    currencies_rates = CurrencyRate.where(upload_file_id: upload_file_ids).includes(:currency)

    products_with_currency_rates = serialize(products_filtered_and_sorted, currencies_rates)
    products_with_currency_rates
  end

  def serialize(products, currencies_rates)
    products_serialized = products.select(:id, :name, :price, :expiration, :code, :upload_file_id)

    products_with_currency_rates = products_serialized.map do |product|
      product.as_json.merge({
        conversion_rates: currencies_rates
        .select { |rate| rate.upload_file_id == product.upload_file_id }
        .map { |rate| { symbol: rate.currency.symbol, name: rate.currency.name, rate: rate.rate } }
      })
    end

    products_with_currency_rates
  end
end