class Distribution < ApplicationRecord
  acts_as_nested_set
  belongs_to :owner, polymorphic: true
end
