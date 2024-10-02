class UploadFile < ApplicationRecord
  validates :file_url, presence: true, uniqueness: true

  has_many :products
  has_many :currency_rates
end