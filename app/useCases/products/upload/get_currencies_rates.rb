class Products::Upload::GetCurrenciesRates
  def initialize(upload_file_id)
    @upload_file_id = upload_file_id
    @basic_currency = "usd"
    @desired_currecies_symbols = [ "eur", "aud", "brl", "cop", "sgd" ]  #  "euro", "australian dollar", "brazilian real", "Colombian Peso", "Singapore Dollar"
  end

  def exec
    response = HTTParty.get("https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/#{@basic_currency}.json")

    if response.success?
      basic_conversion_hash = response.parsed_response[@basic_currency]

      desired_currecies_records = Currency.where(symbol: @desired_currecies_symbols)

      currencies_rates = desired_currecies_records.map do |currency|
        { currency_id: currency.id, rate: basic_conversion_hash[currency.symbol], upload_file_id: @upload_file_id }
      end

      currencies_rates
    else
      raise "Currency API error"
    end
  end
end