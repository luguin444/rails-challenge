class Products::Upload::GetCurrenciesRates
  def initialize()
    @basic_currency = "usd"
    @desired_currecies_symbols = [ "eur", "aud", "brl", "cop", "sgd" ]  #  "euro", "australian dollar", "brazilian real", "Colombian Peso", "Singapore Dollar"
  end

  def exec
    response = HTTParty.get("https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/#{@basic_currency}.json")

    if response.success?
      basic_conversion_hash = response.parsed_response[@basic_currency]

      currencies_rates = @desired_currecies_symbols.map do |currency|
        { "currency": currency, "value": basic_conversion_hash[currency] }
      end

      currencies_rates
    else
      raise "Currency API error"
    end
  end
end