class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true, optional: true
  mount_uploader :media, MediaUploader

  def media_obj
    !media.file.nil? && media.respond_to?(:full_public_id) ? { cloudinary: { public_id: media.file.public_id, type: media.file.resource_type } } : nil
  end
end
