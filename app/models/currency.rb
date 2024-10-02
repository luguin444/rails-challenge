class Currency < ApplicationRecord
  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :currencies_rates
end