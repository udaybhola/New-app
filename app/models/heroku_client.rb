require 'platform-api'
class HerokuClient < ApplicationRecord

  def self.client
    @@heroku ||= PlatformAPI.connect_oauth(ENV['HEROKU_OAUTH_TOKEN'])
    @@heroku
  end

  def self.scale_up_image_maker
    return unless Rails.env.production?
    client.formation.update(ENV['HEROKU_IMAGE_MAKER_APP_NAME'], 'web', size: "performance-l", quantity: 1)
    sleep 5.seconds
  end

  def self.scale_down_image_maker
    return unless Rails.env.production?
    client.formation.update(ENV['HEROKU_IMAGE_MAKER_APP_NAME'], 'web', size: "performance-l", quantity: 0)
    sleep 5.seconds
  end
end
