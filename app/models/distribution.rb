class Distribution < ApplicationRecord
  belongs_to :owner, polymorphic: true
end
