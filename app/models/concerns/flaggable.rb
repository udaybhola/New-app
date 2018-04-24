module Flaggable
  extend ActiveSupport::Concern

  included do
    default_scope { where.not(status: "blocked") }
    has_many :flaggings, dependent: :destroy, as: :flaggable
    has_many :flags, through: :flaggings
    scope :blocked, -> { where(status: "blocked").order('created_at DESC') }
    scope :flagged, -> { where(status: "flagged").order('created_at DESC') }
    scope :approved, -> { where(status: "approved").order('created_at DESC') }

    include AASM
    aasm(:status) do
      state :newly_created, initial: true
      state :flagged
      state :blocked
      state :approved

      event :report do
        transitions from: [:newly_created, :approved], to: :flagged
      end

      event :approve do
        transitions from: [:flagged, :blocked], to: :approved
      end

      event :block do
        transitions from: [:flagged, :approved], to: :blocked
      end
    end
  end

  def flag(reason, user_id)
    flags.build(reason: reason, user_id: user_id)
    report unless flagged?
    save!
  end
end
