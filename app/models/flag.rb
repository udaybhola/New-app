class Flag < ApplicationRecord
  has_many :flaggings, dependent: :destroy
  belongs_to :user
end
