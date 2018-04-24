class Candidature < ApplicationRecord
  include Rails.application.routes.url_helpers
  include Activable
  paginates_per 100

  belongs_to :candidate
  belongs_to :election
  belongs_to :party, optional: true
  has_many :candidate_votes, dependent: :destroy
  belongs_to :constituency
  has_many :messages, dependent: :destroy
  before_destroy :delete_from_influx

  store_accessor :data,
                 :votes_received

  after_create :notify_leaderboard

  RESULTS = %w[pending won lost].freeze

  def commented_posts
    Post.joins(:comments).where("comments.user_id = ?", candidate.profile.user.id)
  end

  def is_voted_by_user(user_id)
    user_id.nil? ? false : candidate_votes.where(user_id: user_id, is_valid: true).count.positive?
  end

  def valid_vote(user_id)
    candidate_votes.where(user_id: user_id).find_by(is_valid: true)
  end

  def cancel_vote(user_id)
    vote = valid_vote(user_id)
    raise Error::CustomError.new(500, "internal_server_error", "No Vote to Cancel") if vote.nil?

    vote.invalidate_vote
  end

  def share_name
    "#{candidate.profile.name} - Profile on Neta App"
  end

  def share_description
    "Vote for your favorite MP and MLA candidates and see which party is leading and which one is going down."
  end

  def share_image_url
    candidate.profile.profile_pic_url
  end

  def total_votes
    candidate_votes.valid.count + initial_votes
  end

  def initial_votes
    votes = 0
    votes = (votes_received.to_i * initial_vote_percent).to_i if votes_received
    votes
  end

  def generate_share_link(force = false)
    url = constituency_candidate_url(constituency, self)

    if !firebase_url.blank? && !force
      return [url, firebase_url]
    else
      firebase_dynamic_link = Firebase::DynamicLink.new(
        title: share_name,
        description: share_description,
        image_url: share_image_url,
        link: url
      )
      short_url, response = firebase_dynamic_link.generate

      self.firebase_url = short_url
      self.firebase_link_response = response
      return [url, firebase_url] if save && !short_url.blank?
    end
    [url, nil]
  end

  def delete_from_influx
    return true if Rails.env.test?
    return true if Influx::EntityInstances.candidature_scoring_measurement
                                          .delete_candidature_measurement(id)
    errors.add :base, "Cannot delete candidature without removing from Influx"
    throw(:abort)
  end

  def notify_leaderboard
    Leaderboards.candidatures.register_candidature_created(self) unless Rails.env.test?
  end
end
