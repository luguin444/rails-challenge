class ProductsController < ApplicationController

  def upload
    file = params[:file]

    if file.nil? || !file.content_type.in?(%w[text/csv application/csv])
      raise Request::BadRequestError.new('File must be sent in CSV format')
    end

    upload_file = Products::Upload::UploadFileToBucket.new(file).exec

    UploadFileJob.perform_async(upload_file.id)

    render json: { status: "File saved and data being processed!", file_url: upload_file.file_url }, status: :ok
  end

  def index
    filter_and_sort_params = params[:q]

    products_with_currency_rates = Products::List::GetSerializedProducts.new(filter_and_sort_params).exec

    render json: { products: products_with_currency_rates }, status: :ok
  end
end