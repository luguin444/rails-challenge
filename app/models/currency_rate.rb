class CurrencyRate < ApplicationRecord
  validates :rate, presence: true
  
  belongs_to :upload_file
  belongs_to :currency
end