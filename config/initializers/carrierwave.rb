if Rails.env.test? || Rails.env.cucumber? || (Rails.env.development? && ENV["CLOUDINARY_URL"].blank?)
  CarrierWave.configure do |config|
    config.storage = :file
    if Rails.env.development?
      config.asset_host = ENV['ASSET_HOST'] || "http://localhost:3000"
    end
    if Rails.env.test? || Rails.env.cucumber?
      config.enable_processing = false
    end
  end
end
