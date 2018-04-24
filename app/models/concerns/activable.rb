module Activable
  extend ActiveSupport::Concern

  included do
    has_many :activities, as: :activable, dependent: :destroy
    after_create :add_activity
  end

  def add_activity
    ActivityJob.perform_later(id: id, type: self.class.name)
  end

  def create_activity(*args)
    activities.create(args[0])
  end
end
