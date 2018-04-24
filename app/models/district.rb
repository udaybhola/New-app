class District < ApplicationRecord
  belongs_to :country_state
  has_and_belongs_to_many :constituencies

  validates :name, presence: true
  validates :country_state, presence: true

  before_save :generate_slug

  def generate_slug
    self.slug = "#{country_state.slug}-#{name.parameterize}"
  end
end
