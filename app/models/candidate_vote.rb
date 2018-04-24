class CandidateVote < ApplicationRecord
  include Activable

  belongs_to :user
  belongs_to :candidature
  belongs_to :election
  belongs_to :previous_vote, optional: true, class_name: 'CandidateVote'
  belongs_to :new_vote, optional: true, class_name: 'CandidateVote'

  scope :valid, -> { where(is_valid: true, archived: false) }

  before_validation :assign_election, on: :create
  before_create :invalidate_old_votes
  after_create :update_next_vote, :notify_leaderboard
  default_scope { where(archived: false) }

  def assign_election
    self.election = candidature.election
  end

  def invalidate_old_votes
    CandidateVote
      .where(user: user, election: election)
      .order('created_at DESC')
      .update_all(is_valid: false)
  end

  def invalidate_vote
    new_vote = CandidateVote.create(candidature: candidature, user: user, election: election, is_valid: false, previous_vote: self)
    self.new_vote = new_vote
    save
    new_vote
  end

  def update_next_vote
    unless previous_vote.nil?
      previous_vote.new_vote = self
      previous_vote.save
    end
  end

  def notify_leaderboard
    Leaderboards.candidatures.register_candidature_voted(self) unless Rails.env.test?
  end
end
