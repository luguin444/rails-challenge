require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Products::Upload::GetCurrenciesRates do
  let!(:upload_file) { FactoryBot.create(:upload_file) }
  let!(:currency_eur) { FactoryBot.create(:currency, symbol: "eur") }
  let!(:currency_aud) { FactoryBot.create(:currency, symbol: "aud") }
  let!(:currency_brl) { FactoryBot.create(:currency, symbol: "brl") }
  let!(:currency_cop) { FactoryBot.create(:currency, symbol: "cop") }
  let!(:currency_sgd) { FactoryBot.create(:currency, symbol: "sgd") }

  describe 'exec' do
    context 'when the API call is successful' do
      before do
        stub_request(:get, "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json")
          .to_return(status: 200, body: {
            "usd": {
              "eur": 0.85,
              "aud": 1.34,
              "brl": 5.24,
              "cop": 3700,
              "sgd": 1.35
            }
          }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it "should return expected rates in the correct format" do
        expected_rates = [
          { currency_id: Currency.find_by(symbol: 'eur').id, rate: 0.85, upload_file_id: upload_file.id },
          { currency_id: Currency.find_by(symbol: 'aud').id, rate: 1.34, upload_file_id: upload_file.id },
          { currency_id: Currency.find_by(symbol: 'brl').id, rate: 5.24, upload_file_id: upload_file.id },
          { currency_id: Currency.find_by(symbol: 'cop').id, rate: 3700, upload_file_id: upload_file.id },
          { currency_id: Currency.find_by(symbol: 'sgd').id, rate: 1.35, upload_file_id: upload_file.id }
        ]

        result = Products::Upload::GetCurrenciesRates.new(upload_file.id).exec

        expect(result).to match_array(expected_rates)
      end
    end

    context 'when the API call fails' do
      before do
        stub_request(:get, "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json")
          .to_return(status: 500)
      end

      it 'raises an error' do
        service = Products::Upload::GetCurrenciesRates.new(upload_file.id)
        expect { service.exec }.to raise_error("Currency API error")
      end
    end
  end
end