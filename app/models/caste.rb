class Caste < ApplicationRecord
  validates :name, presence: true
  has_many :profiles

  default_scope { order('name ASC') }
end
