class PartyMembership < ApplicationRecord
  include Activable

  belongs_to :user
  belongs_to :party
  belongs_to :constituency

  scope :valid, -> { where(is_valid: true) }

  before_create :invalidate_old_memberships

  def invalidate_old_memberships
    PartyMembership
      .where(user: user)
      .order('created_at DESC')
      .update_all(is_valid: false)
  end
end
