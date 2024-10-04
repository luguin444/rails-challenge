RSpec.describe UploadFileJob, type: :job do
  let!(:upload_file) { FactoryBot.create(:upload_file) }
  let!(:local_file_path) { '/tmp/file.csv' }
  let!(:valid_products) { [
    { name: "Product 1", price: 100, code: "1", expiration: "1/11/2023", upload_file_id: upload_file.id }, 
    { name: "Product 2", price: 200, code: "2", expiration: "2/13/2020", upload_file_id: upload_file.id }
  ] }
  let!(:currencies_rates) { [{ currency_id: 1, rate: 0.85, upload_file_id: upload_file.id }] }
  let!(:errors) { [] }

  describe 'perform' do
    before do
      mock_dowload = instance_double(Products::Upload::DownloadFileFromBucket, exec: local_file_path)
      allow(Products::Upload::DownloadFileFromBucket).to receive(:new).with(upload_file.file_url).and_return(mock_dowload)

      mock_get_valid_products = instance_double(Products::Upload::GetValidProductsFromFile, exec: [valid_products, errors])
      allow(Products::Upload::GetValidProductsFromFile).to receive(:new).with(local_file_path, upload_file.id).and_return mock_get_valid_products

      mock_get_currencies = instance_double(Products::Upload::GetCurrenciesRates, exec: currencies_rates)
      allow(Products::Upload::GetCurrenciesRates).to receive(:new).with(upload_file.id).and_return mock_get_currencies
    end

    it 'should call all necessary methods' do
      expect(Products::Upload::DownloadFileFromBucket).to receive(:new).with(upload_file.file_url)
      expect(Products::Upload::GetValidProductsFromFile).to receive(:new).with(local_file_path, upload_file.id)
      expect(Products::Upload::GetCurrenciesRates).to receive(:new).with(upload_file.id)

      expect(Product).to receive(:insert_all).with(valid_products)
      expect(CurrencyRate).to receive(:insert_all).with(currencies_rates)
      expect_any_instance_of(UploadFileJob).to receive(:notify_user).with(valid_products, errors)

      UploadFileJob.new.perform(upload_file.id)
    end
  end
end
