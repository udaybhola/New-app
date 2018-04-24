class MediaUploader < BaseUploader
  def content_type_whitelist
    /image\//
  end
end
