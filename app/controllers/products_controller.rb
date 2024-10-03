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
    filter_and_sort_params = params[:q]

    products_with_currency_rates = Products::List::GetSerializedProducts.new(filter_and_sort_params).exec

    render json: { products: products_with_currency_rates }, status: :ok
  end
end