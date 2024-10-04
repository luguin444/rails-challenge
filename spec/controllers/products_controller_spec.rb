require 'rails_helper'

RSpec.describe ProductsController, type: :request do
  describe 'GET /products' do
    let!(:productA) { FactoryBot.create(:product, name: 'Product A', price: 100) }
    let!(:productB) { FactoryBot.create(:product, name: 'Product B', price: 200) }
    let!(:productC) { FactoryBot.create(:product, name: 'Product C', price: 300) }

    context 'when no query params are passed' do
      it 'should return all products' do
        get "/products"

        expect(response).to have_http_status(:ok)
        expect(json_response['products'].size).to eq(3)
      end
    end

    it 'should order the products by name DESC' do
      sort_params = "q[s]=name+desc"
      get "/products?#{sort_params}"

      expect(response).to have_http_status(:ok)
      expect(json_response['products'].map { |p| p['name'] }).to eq(['Product C', 'Product B', 'Product A'])
    end

    it 'should filters the products by price greater than 200, only product C' do
      filter_params = "q[price_gt]=200"
      get "/products?#{filter_params}"

      expect(response).to have_http_status(:ok)
      expect(json_response['products'].size).to eq(1)
      expect(json_response['products'].first['id']).to eq(productC[:id])
    end

    it 'should return correct keys' do
      filter_params = "q[price_gt]=200"
      get "/products?#{filter_params}"

      product_response = json_response['products'][0]
      expect(product_response).to include(
          'id' => productC[:id],
          'name' => productC[:name],
          'price' => productC[:price],
          'expiration' => productC[:expiration],
          'code' => productC[:code],
          'upload_file_id' => productC[:upload_file_id],
          'conversion_rates' => be_an(Array)
        )
    end
  end

  describe 'POST /products/upload' do
    let!(:productA) { FactoryBot.create(:product, name: 'Product A', price: 100) }
    let!(:productB) { FactoryBot.create(:product, name: 'Product B', price: 200) }
    let!(:productC) { FactoryBot.create(:product, name: 'Product C', price: 300) }

    it 'should return a 400 error, since no file was provided' do
      post "/products/upload", params: { file: nil }

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to include({"message" => "File must be sent in CSV format"})
    end

    it 'should return a 400 error, since file is not CSV' do
      pdf_file = fixture_file_upload('spec/fixtures/test.pdf', 'application/pdf')
      post "/products/upload", params: { file: pdf_file }

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to include({"message" => "File must be sent in CSV format"})
    end

    it 'should return a 200 status and processes the file' do
      upload_file = FactoryBot.create(:upload_file)
      expect_any_instance_of(Products::Upload::UploadFileToBucket).to receive(:exec).and_return upload_file
      expect(UploadFileJob).to receive(:perform_async).with(upload_file.id)

      csv_file = fixture_file_upload('spec/fixtures/integration_test.csv', 'application/csv')
      post "/products/upload", params: { file: csv_file }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('File saved and data being processed!')
    end

  end

  def json_response
    JSON.parse(response.body)
  end
end