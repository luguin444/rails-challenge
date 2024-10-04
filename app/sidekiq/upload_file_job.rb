class UploadFileJob
  include Sidekiq::Job

  def perform(upload_file_id)
    upload_file = UploadFile.find(upload_file_id)
    local_file_path = Products::Upload::DownloadFileFromBucket.new(upload_file.file_url).exec

    valid_products, errors = Products::Upload::GetValidProductsFromFile.new(local_file_path, upload_file.id).exec
    currencies_rates = Products::Upload::GetCurrenciesRates.new(upload_file.id).exec

    Product.insert_all(valid_products)
    CurrencyRate.insert_all(currencies_rates)

    notify_user(valid_products, errors)
  end

  def notify_user(valid_products, errors)
    puts "Notifying user"
    puts  "Products inserted: #{valid_products.length}"
    puts  "Number of errors: #{errors.length}"
    puts  "First Error: #{errors[0]&.inspect}"

    # TODO: send email or slack with data
  end
end
