FactoryBot.define do
  factory :upload_file, class: UploadFile do
    file_url { Faker::Internet.url }
  end
end