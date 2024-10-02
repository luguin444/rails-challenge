class ProductsController < ApplicationController

  def upload
    file = params[:file]

    if file.nil? || !file.content_type.in?(%w[text/csv application/csv])
      raise Request::BadRequestError.new('File must be sent in CSV format')
    end

    upload_file = Products::Upload::UploadFileToBucket.new(file).exec
    valid_products, errors = Products::Upload::GetValidProductsFromFile.new(file, upload_file.id).exec
    currencies_rates = Products::Upload::GetCurrenciesRates.new(upload_file.id).exec

    Product.insert_all(valid_products)
    CurrencyRate.insert_all(currencies_rates)

    render json: { products_inserted: valid_products.length, errors: { quantity: errors.length, details: errors } } , status: :ok
  end

  def index
    products = Product.select(:id, :name, :price, :expiration, :code, :upload_file_id)
    upload_file_ids = products.map(&:upload_file_id)
    currencies_rates = CurrencyRate.includes(:currency).where(upload_file_id: upload_file_ids)

    products_with_currency_rates = products.map do |product|
      product.as_json.merge({
        conversion_rates: currencies_rates
        .select { |rate| rate.upload_file_id == product.upload_file_id }
        .map { |rate| { symbol: rate.currency.symbol, name: rate.currency.name, rate: rate.rate } }
      })
    end

    render json: { products: products_with_currency_rates }, status: :ok
  end
end