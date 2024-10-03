FactoryBot.define do
  factory :product, class: Product do
    association :upload_file

    name { Faker::Commerce.product_name }
    code { "4026987913289674" }
    price { rand(0..10000) }
    expiration { Faker::Date.between(from: Date.today, to: Date.today + 1.year).strftime("%d/%m/%Y") }
  end
end