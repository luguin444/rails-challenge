require 'rails_helper'

RSpec.describe Products::Upload::GetValidProductsFromFile do
  let(:local_file_path) { "spec/fixtures/test.csv" }
  let!(:upload_file) { FactoryBot.create(:upload_file) }

  before do
    CSV.open(local_file_path, 'w', col_sep: ';', force_quotes: false) do |csv|
      csv << ['name','price','expiration']
      csv << ['Calypso - Lemonade #(402)','$115.55','1/11/2023']
      csv << ['Cheese - Grana Padano #(357)','$163.88','1/14/2023']
      csv << ['Error in name_code #(<img src=x onerror=alert() />)','$70.85','1/3/2023']
      csv << ['Error in price #(356)','', '1/3/2023']
      csv << ['Error in expiration / Leek #(3566)','$13.10','']
      csv << ['Veal - Loin #(555)','$72.60','12/16/2022']
    end
  end

  after do
    File.delete(local_file_path)
  end

  describe 'exec' do
    it 'should return correct products and errors' do
      service = Products::Upload::GetValidProductsFromFile.new(local_file_path, upload_file.id)
      products, errors = service.exec()

      expect(products.length).to eq(3)
      expect(errors.length).to eq(3)
      expect(products).to include({:name=>"Calypso - Lemonade", :price=>11555, :expiration=>"01/11/2023", :code=>"402", :upload_file_id=>upload_file.id})
      expect(products).to include({:name=>"Cheese - Grana Padano", :price=>16388, :expiration=>"01/14/2023", :code=>"357", :upload_file_id=>upload_file.id})
      expect(products).to include({:name=>"Veal - Loin", :price=>7260, :expiration=>"12/16/2022", :code=>"555", :upload_file_id=>upload_file.id})
      expect(errors).to include({:csv_error_line=>4, :error=>"Invalid format for name_with_code"})
      expect(errors).to include({:csv_error_line=>5, :error=>"Invalid price format"})
      expect(errors).to include({:csv_error_line=>6, :error=>"Invalid expiration date format"})
    end
  end

  describe 'sanitize_name_with_code' do
    it 'should return correct name and code' do
      service = Products::Upload::GetValidProductsFromFile.new(local_file_path, upload_file.id)
      expect(service.sanitize_name_with_code('Calypso - Lemonade #(4026987913289674)')).to eq(["Calypso - Lemonade",  "4026987913289674"])
      expect(service.sanitize_name_with_code('Veal - Loin #(5552033378109898)')).to eq(["Veal - Loin",  "5552033378109898"])
    end

    it 'should raise an error for invalid name and code format' do
      service = Products::Upload::GetValidProductsFromFile.new(local_file_path, upload_file.id)

      expect { service.sanitize_name_with_code("Fib N9 - Prague Powder #(<>?:""{}|_+)") }.to raise_error("Invalid format for name_with_code")
      expect { service.sanitize_name_with_code("Lemonade - Mandarin, 591 Ml #(1;DROP TABLE users)") }.to raise_error("Invalid format for name_with_code")
      expect { service.sanitize_name_with_code("Lemonade - Mandarin, 591 Ml #()") }.to raise_error("Invalid format for name_with_code")
    end
  end

  describe 'sanitize_price' do
    it 'should convert a valid price to cents' do
      service = Products::Upload::GetValidProductsFromFile.new(local_file_path, upload_file.id)
      expect(service.sanitize_price('$12.34')).to eq(1234)
      expect(service.sanitize_price('€45.67')).to eq(4567)
      expect(service.sanitize_price('100.00')).to eq(10000)
    end

    it 'should raise an error for invalid price format' do
      service = Products::Upload::GetValidProductsFromFile.new(local_file_path, upload_file.id)

      expect { service.sanitize_price('invalid') }.to raise_error("Invalid price format")
      expect { service.sanitize_price(nil) }.to raise_error("Invalid price format")
    end
  end

  describe 'sanitize_expiration' do
    it "should return date in correct format" do

      result = Products::Upload::GetValidProductsFromFile.new(local_file_path, upload_file.id).sanitize_expiration("1/10/2021")

      expect(result).to eq("01/10/2021")
    end

    it "should raise error, since it is not a date" do
      service = Products::Upload::GetValidProductsFromFile.new(local_file_path, upload_file.id)
      expect { service.sanitize_expiration("14/14/2024") }.to raise_error("Invalid expiration date format")
      expect { service.sanitize_expiration(nil) }.to raise_error("Invalid expiration date format")
      expect { service.sanitize_expiration("invalid") }.to raise_error("Invalid expiration date format")
    end
  end
end