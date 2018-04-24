class PollVote < ApplicationRecord
  include Activable

  belongs_to :poll_option
  belongs_to :user
  belongs_to :poll

  scope :valid, -> { where(is_valid: true, archived: false) }

  before_validation :assign_poll, on: :create
  before_create :invalidate_old_votes
  after_create :increment_poll_votes_count
  default_scope { where(archived: false) }

  attr_accessor :earlier_successful_poll_vote

  def previous_votes
    PollVote.where(poll_id: poll_id, user_id: user_id).where.not(poll_option_id: poll_option_id)
            .where('created_at < ?', created_at).order('created_at desc')
  end

  def assign_poll
    self.poll = poll_option.poll
  end

  def invalidate_old_votes
    @earlier_successful_poll_vote = PollVote.where(user: user, poll: poll, is_valid: true).first
    PollVote
      .where(user: user, poll: poll)
      .order('created_at DESC')
      .update_all(is_valid: false)
  end

  def increment_poll_votes_count
    unless @earlier_successful_poll_vote.nil?
      earlier_poll_option = @earlier_successful_poll_vote.poll_option
      if earlier_poll_option.poll_votes_count > 0
        earlier_poll_option.poll_votes_count = earlier_poll_option.poll_votes_count - 1
        earlier_poll_option.save
      end
    end

    poll_option.poll_votes_count = poll_option.poll_votes_count + 1
    poll_option.save
  end
end
