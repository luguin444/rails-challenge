FactoryBot.define do
  factory :currency, class: Currency do
    symbol { "#{Faker::Currency.code}_#{SecureRandom.hex(2)}" }
    name { "US Dollar" }
  end
end