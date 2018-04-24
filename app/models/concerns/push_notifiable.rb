module PushNotifiable
  extend ActiveSupport::Concern

  included do
    after_create :queue_notification_job
  end

  def queue_notification_job
    if ENV['SIMULATION_MODE'].to_i == 1
      Rails.logger.debug "Skip: If simulation mode is set, wont be sending notifications"
    else
      # PushNotificationJob.perform_later(id: id, type: self.class.name)
    end
  end
end
