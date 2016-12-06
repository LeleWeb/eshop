class Collection < ApplicationRecord
  belongs_to :object, polymorphic: true
  belongs_to :owner, polymorphic: true
end
