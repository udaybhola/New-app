class Activity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :activable, polymorphic: true

  store_accessor :meta,
                 :meta_action,
                 :meta_object

  store_accessor :details,
                 :author,
                 :title,
                 :question,
                 :text

  default_scope { where(archived: false) }

  def name
    "You #{meta_action} #{meta_object}"
  end
end
