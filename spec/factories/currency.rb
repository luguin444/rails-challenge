FactoryBot.define do
  factory :currency, class: Currency do
    symbol { Faker::Currency.code }
    name { "US Dollar" }
  end
end