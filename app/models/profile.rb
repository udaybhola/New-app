class Profile < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :candidate, optional: true

  belongs_to :religion, optional: true
  belongs_to :caste, optional: true
  # belongs_to :education, optional: true
  belongs_to :profession, optional: true

  mount_uploader :profile_pic, ImageUploader
  mount_uploader :cover_photo, ImageUploader

  store_accessor :contact,
                 :phone,
                 :phone2,
                 :email,
                 :website,
                 :twitter,
                 :facebook,
                 :pincode

  store_accessor :financials,
                 :income,
                 :assets,
                 :liabilities

  store_accessor :civil_record,
                 :education,
                 :criminal_cases,
                 :qualification

  store_accessor :status,
                 :registered_to_vote

  before_save :generate_slug, :set_vote_status

  scope :candidate, -> { where("candidate_id IS NOT NULL") }

  def generate_slug
    self.slug = name.parameterize if name
  end

  def set_vote_status
    self.registered_to_vote = registered_to_vote.nil? ? false : registered_to_vote
  end

  def profile_pic_obj
    !profile_pic.file.nil? && profile_pic.respond_to?(:full_public_id) ? { cloudinary: { public_id: profile_pic.file.public_id } } : nil
  end

  def cover_photo_obj
    !cover_photo.file.nil? && cover_photo.respond_to?(:full_public_id) ? { cloudinary: { public_id: cover_photo.file.public_id } } : nil
  end

  def age
    Time.now.year - date_of_birth.year if date_of_birth
  end
end
