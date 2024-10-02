class Product < ApplicationRecord
  validates :name, :price, :expiration, :code, :upload_file_id, presence: true
  
  belongs_to :upload_file
end