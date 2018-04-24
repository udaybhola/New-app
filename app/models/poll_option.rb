class PollOption < ApplicationRecord
  belongs_to :poll
  has_many :poll_votes, dependent: :destroy
  mount_uploader :image, MediaUploader

  validates :answer, presence: true

  def image_obj
     !image.file.nil? && image.respond_to?(:full_public_id) ? { cloudinary: { public_id: image.file.public_id } } : nil
  end
end
