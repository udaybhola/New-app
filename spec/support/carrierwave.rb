Dir["#{Rails.root}/app/uploaders/*.rb"].each { |file| require file }
require 'carrierwave/test/matchers'

RSpec.configure do |config|
  if defined?(CarrierWave)
    CarrierWave::Uploader::Base.descendants.each do |klass|
      next if klass.anonymous?

      klass.class_eval do
        def cache_dir
          "#{Rails.root}/public/test/support/uploads/cache"
        end

        def store_dir
          "#{Rails.root}/public/test/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end
      end
    end
  end

  config.after(:all) do
    if Rails.env.test?
      FileUtils.rm_rf(Dir["#{Rails.root}/public/test/support/uploads"])
    end
  end

  config.include CarrierWave::Test::Matchers
end
