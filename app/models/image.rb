class Image < ApplicationRecord
  mount_uploader :picture, PictureUploader
  has_many :documents, dependent: :destroy
  attr_accessor :document_data
end
