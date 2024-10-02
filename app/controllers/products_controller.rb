class ProductsController < ApplicationController

  def upload
    # puts "entrei na rota"
    file = params[:file]

    if file.nil? || !file.content_type.in?(%w[text/csv application/csv])
      raise Request::BadRequestError.new('File must be sent in CSV format')
    end

    # Products::Upload::UploadFileToBucket.new(file).exec
    valid_products, errors = Products::Upload::GetValidProductsFromFile.new(file).exec




    puts "fim da rota"

    # # Verifica o tamanho do arquivo (exemplo: até 10MB)
    # if file.size > 10.megabytes
    #   return render json: { error: 'Arquivo muito grande' }, status: :bad_request
    # end

    render json: { products_inserted: valid_products.length, errors: { quantity: errors.length, details: errors } } , status: :ok
  end
end