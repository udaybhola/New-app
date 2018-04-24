class Like < ApplicationRecord
  include Activable
  include PushNotifiable

  belongs_to :user
  belongs_to :likeable, polymorphic: true, optional: true, counter_cache: true
  default_scope { where(archived: false) }
end
