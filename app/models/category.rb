class Category < ApplicationRecord
  validates :name, presence: true
  mount_uploader :image, ImageUploader

  before_save :generate_slug

  def generate_slug
    self.slug = name.parameterize
  end
end
