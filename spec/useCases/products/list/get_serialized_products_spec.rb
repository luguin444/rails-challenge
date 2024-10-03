require 'rails_helper'

RSpec.describe Products::List::GetSerializedProducts do
  let!(:first_upload_file) { FactoryBot.create(:upload_file) }
  let!(:second_upload_file) { FactoryBot.create(:upload_file) }

  let!(:first_product) { FactoryBot.create(:product, name: "1", price: 1, upload_file: first_upload_file) }
  let!(:second_product) { FactoryBot.create(:product, name: "2", price: 2, upload_file: second_upload_file) }

  let!(:first_currency_rate) { FactoryBot.create(:currency_rate, upload_file: first_upload_file ) }
  let!(:second_currency_rate) { FactoryBot.create(:currency_rate, upload_file: second_upload_file ) }

  describe 'exec' do  
    it 'should return all products with no filtering and sorting' do
      filter_params = nil

      result = Products::List::GetSerializedProducts.new(filter_params).exec

      expect(result.size).to eq(2)
    end

    it 'should return only the first product, since it is filtered by the name equalty' do
      filter_params = {"name_eq" => "1"}

      result = Products::List::GetSerializedProducts.new(filter_params).exec

      expect(result.size).to eq(1)
      expect(result[0]["id"]).to eq(first_product[:id])
    end

    it 'should return products ordered by price DESC, since it is sorted by this param' do
      sort_params = {"s" => "price desc"}

      result = Products::List::GetSerializedProducts.new(sort_params).exec

      expect(result.size).to eq(2)
      expect(result[0]["id"]).to eq(second_product[:id])
      expect(result[1]["id"]).to eq(first_product[:id])
    end

    it 'should call serialize with only the first product and the currency_rate from this file' do
      filter_params = {"name_eq" => "1"}
      service = Products::List::GetSerializedProducts.new(filter_params)
      allow(service).to receive(:serialize)

      expected_products = Product.where(id: first_product.id)
      expecpted_currency_rates = CurrencyRate.where(upload_file_id: first_product.upload_file_id).includes(:currency)

     service.exec()

      expect(service).to have_received(:serialize).with(
        match_array(expected_products),
        expecpted_currency_rates
      )
    end

    it 'should return the return from the serialized function' do
      expected_result = "serialized_result"

      service = Products::List::GetSerializedProducts.new(nil)
      allow(service).to receive(:serialize).and_return(expected_result)

     result = service.exec()

      expect(result).to eq(expected_result)
    end
  end

  describe 'serialize' do
    it 'should delete timestamps properties from products' do
      products = Product.where(id: [first_product.id, second_product.id])
      currencies_rates = [first_currency_rate, second_currency_rate]

      service = Products::List::GetSerializedProducts.new(nil)
      products_serialized = service.serialize(products, currencies_rates)

      [first_product, second_product].each_with_index do |product, index|
        expect(products_serialized[index]).not_to have_key("created_at")
        expect(products_serialized[index]).not_to have_key("updated_at")
      end
    end

    it 'should insert only the conversion rates from file with correct params' do
      products = Product.where(id: [first_product.id, second_product.id])
      currencies_rates = [first_currency_rate, second_currency_rate]

      service = Products::List::GetSerializedProducts.new(nil)
      products_serialized = service.serialize(products, currencies_rates)

      currencies_rates.each_with_index do |currency_rate, index|
        conversion_rates = products_serialized[index][:conversion_rates]

        expect(conversion_rates.size).to eq(1)

        expect(conversion_rates[0]).to include({
          :symbol => currency_rate.currency.symbol,
          :name => currency_rate.currency.name,
          :rate => currency_rate.rate,
        })
      end
    end

    it 'should return products with correct params' do
      products = Product.where(id: [first_product.id, second_product.id])
      currencies_rates = [first_currency_rate, second_currency_rate]

      service = Products::List::GetSerializedProducts.new(nil)
      products_serialized = service.serialize(products, currencies_rates)

      [first_product, second_product].each_with_index do |product, index|
        expect(products_serialized[index]).to include({
          "id" => product.id,
          "name" => product.name,
          "price" => product.price,
          "expiration" => product.expiration,
          "code" => product.code,
          "upload_file_id" => product.upload_file_id,
        })
      end
    end
  end
end
