class Message < ApplicationRecord
  belongs_to :candidature
  has_one :candidate, through: :candidature
  has_one :attachment, as: :attachable

  validates :title, presence: true
end
