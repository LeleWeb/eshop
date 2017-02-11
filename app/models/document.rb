class Document < ApplicationRecord
  belongs_to :image
  mount_uploader :document, DocumentUploader
end
