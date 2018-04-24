class BaseUploader < CarrierWave::Uploader::Base
  if Rails.env.test? || Rails.env.cucumber? || (Rails.env.development? && ENV["CLOUDINARY_URL"].blank?)
    include CarrierWave::MiniMagick
    define_method 'store_dir' do
      return "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  else
    include Cloudinary::CarrierWave
  end
end
