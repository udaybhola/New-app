class Party < ApplicationRecord
  paginates_per 100

  has_many :candidatures
  has_many :party_memberships
  has_many :party_leaders

  mount_uploader :image, ImageUploader
  mount_uploader :manifesto, DocumentUploader
  store_accessor :contact,
                 :phone,
                 :phone2,
                 :email,
                 :website,
                 :twitter,
                 :facebook

  default_scope { order('abbreviation ASC') }
  validates :color, css_hex_color: true, allow_blank: true

  validates :abbreviation, presence: true, uniqueness: true

  def party_image_obj
    !image.file.nil? && image.respond_to?(:full_public_id) ? { cloudinary: { public_id: image.file.public_id } } : nil
  end

  def title
    name.blank? ? abbreviation : name
  end

  def label
    abbreviation
  end
end
