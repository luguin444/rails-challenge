class UploadFile < ApplicationRecord
  validates :file_url, presence: true, uniqueness: true
end