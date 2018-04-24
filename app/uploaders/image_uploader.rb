class ImageUploader < BaseUploader
  def content_type_whitelist
    /image\//
  end

  version :thumb do
    process resize_to_fill: [120, 120]
  end

  version :icon do
    process resize_to_fill: [40, 40]
  end
end
