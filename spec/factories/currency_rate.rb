FactoryBot.define do
  factory :currency_rate, class: CurrencyRate do
    association :currency
    association :upload_file

    rate { Faker::Number.decimal(l_digits: 1, r_digits: 8) }
  end
end