class User < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Activable
  paginates_per 100

  attr_accessor :skip_password_validation

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  belongs_to :assembly_constituency, class_name: 'Constituency', foreign_key: 'constituency_id', optional: true
  has_one :country_state, through: :assembly_constituency

  has_many :posts, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :polls, dependent: :destroy
  has_many :poll_votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_one  :profile, dependent: :destroy
  has_many :candidate_votes, dependent: :destroy
  has_many :party_memberships, dependent: :destroy
  has_many :activities, dependent: :destroy
  belongs_to :constituency, optional: true
  before_update :remove_influencer_from_redis, :if => :constituency_id_changed?

  default_scope { where.not(archived: true) }

  def my_posts
    activities.where(activable_type: [Post.name, PollVote.name, Comment.name, Like.name]).order('created_at DESC')
  end

  def parliamentary_constituency
    assembly_constituency.try(:parent)
  end

  def valid_poll_votes
    poll_votes.where(is_valid: true)
  end

  def already_voted?(candidature)
    candidate_votes.valid.where(candidature_id: candidature.id).count > 0
  end

  def previous_vote(election)
    candidate_votes.valid.find_by(election: election)
  end

  def total_score
    activities.map(&:score).reduce(:+)
  end

  def public_activities
    activities_id_arr =  activities.reject { |activity| activity.activable_type == Post.name && !activity.activable.nil? && activity.activable.anonymous }.map(&:id)
    activities.where(id: activities_id_arr)
  end

  def share_name
    "#{profile.name} - Profile on Neta App"
  end

  def share_description
    "Make Your Voice Heard; Participate in daily polls about your Government and its policies. Cast your Vote; Vote for MP or MLA candidates based on their performance. Report Issues; See if your candidates take up your issues and work on them."
  end

  def share_image_url
    profile.profile_pic_url
  end

  def constituency_name
    constituency&.name&.titleize
  end

  def notification_name
    profile&.name&.titleize
  end

  def generate_share_link(force = false)
    url = constituency_influencer_url(constituency, self)
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

  def mark_as_inactive
    self.transaction do 
      affected_user_ids = []
      all_activity_ids = []
      
      Rails.logger.debug "===============STARTED ARCHIVING OF USER: #{id} ==============================="
      Rails.logger.debug "examining posts to be archived"
      posts.each do |post|
        Rails.logger.debug "================================================"
        Rails.logger.debug "Examining for post id: #{post.id}, type: #{post.type}"
        unless post.user_level?
          Rails.logger.debug "Post is not userlevel post, so nothing to do here"
          Rails.logger.debug "Finished for post id: #{post.id}, type: #{post.type}"
          next
        end

        post_related_activities = post.related_activity_ids
        related_activities = Activity.where(id: post_related_activities)
        affected_user_ids = affected_user_ids + related_activities.map(&:user_id)
        all_activity_ids = all_activity_ids + related_activities.ids

        Rails.logger.debug "User ids to recalibrate: #{related_activities.map(&:user_id)}"
        Rails.logger.debug "Activity ids to recalibrate: #{related_activities.ids}"
        Rails.logger.debug "Finished for post id: #{post.id}, type: #{post.type}"
        Rails.logger.debug "================================================"
      end
      Rails.logger.debug "finished examining posts to be archived. No of Posts: #{posts.count}"
      
      Rails.logger.debug "================================================"
      Rails.logger.debug "examining comments to be archived"
      comments.each do |comment|
        Rails.logger.debug "================================================"
        Rails.logger.debug "Examining comment id: #{comment.id}"
        unless comment.children.blank?
          comment_ids = comment.children.ids + [comment.id]
          related_activities = Activity.where(activable_id: comments_ids)
          affected_user_ids = affected_user_ids + related_activities.map(&:user_id)
          all_activity_ids = all_activity_ids + related_activities.ids
          Rails.logger.debug "For Children Comments, User ids to recalibrate: #{related_activities.map(&:user_id)}"
          Rails.logger.debug "For Children Comments, Activity ids to recalibrate: #{related_activities.ids}"
        end
        unless comment.parent.blank?
          comment_ids = comment.id + [comment.parent.id]
          related_activities = Activity.where(activable_id: comment_ids)
          affected_user_ids = affected_user_ids + related_activities.map(&:user_id)
          all_activity_ids = all_activity_ids + related_activities.ids
          Rails.logger.debug "For Parent Comments, User ids to recalibrate: #{related_activities.map(&:user_id)}"
          Rails.logger.debug "For Parent Comments, Activity ids to recalibrate: #{related_activities.ids}"
        end
        Rails.logger.debug "Finished for comment id: #{comment.id}"
        Rails.logger.debug "================================================"
      end
      Rails.logger.debug "finished examining comments to be archived.No of Comments: #{comments.count}"
      
      Rails.logger.debug "================================================"
      Rails.logger.debug "examining likes to be archived"
      like_ids = likes.ids
      like_activities = Activity.where(activable_id: like_ids)
      affected_user_ids = affected_user_ids + like_activities.map(&:user_id)
      all_activity_ids = all_activity_ids + like_activities.ids
      Rails.logger.debug "User ids to recalibrate: #{like_activities.map(&:user_id)}"
      Rails.logger.debug "Activity ids to recalibrate: #{like_activities.ids}"
      Rails.logger.debug "finished examining likes to be archived."

      Rails.logger.debug "================================================"
      Rails.logger.debug "examining poll votes to be archived"
      poll_votes_ids = poll_votes.ids
      poll_votes_activities = Activity.where(activable_id: poll_votes_ids)
      affected_user_ids = affected_user_ids + poll_votes_activities.map(&:user_id)
      all_activity_ids = all_activity_ids + poll_votes_activities.ids
      Rails.logger.debug "User ids to recalibrate: #{poll_votes_activities.map(&:user_id)}"
      Rails.logger.debug "Activity ids to recalibrate: #{poll_votes_activities.ids}"
      Rails.logger.debug "finished examining poll votes to be archived."

      Rails.logger.debug "================================================"
      Rails.logger.debug "examining candidate votes to be archived"
      candidate_vote_ids = candidate_votes.ids
      candidate_votes_activities = Activity.where(activable_id: candidate_vote_ids)
      candidature_ids = candidate_votes.valid.map(&:candidature_id)
      affected_user_ids =  affected_user_ids + candidate_votes_activities.map(&:user_id)
      all_activity_ids = all_activity_ids + candidate_votes_activities.ids
      Rails.logger.debug "Candidatures to recalibrate: #{candidature_ids}"
      Rails.logger.debug "User ids to recalibrate: #{candidate_votes_activities.map(&:user_id)}"
      Rails.logger.debug "Activity ids to recalibrate: #{candidate_votes_activities.ids}"
      Rails.logger.debug "finished examining candidate votes to be archived."

      Rails.logger.debug "================================================"
      Rails.logger.debug "List of final activity ids: #{all_activity_ids}."
      Rails.logger.debug "List of final user_ids ids: #{(affected_user_ids + [id]).uniq}."
      Rails.logger.debug "Estimated new score of user : #{total_score - Activity.unscoped.where(id: all_activity_ids, user_id: id).map(&:score).reduce(:+)}"
      Activity.where(id: all_activity_ids).update_all(archived: true)
      posts.update_all(archived: true)
      comments.update_all(archived: true)
      likes.update_all(archived: true)
      candidate_votes.update_all(archived: true)
      poll_votes.update_all(archived: true)

      uniq_user_ids = (affected_user_ids + [id]).uniq
      Rails.logger.debug "================================================"
      Rails.logger.debug "Uniq user ids to recalibrate: #{uniq_user_ids}"
      Leaderboards.influencers.reset_influencer_scores(uniq_user_ids) unless Rails.env.test?
      Leaderboards.candidatures.reset_candidates_scores(candidature_ids) unless Rails.env.test?
      update_attributes(archived: true)
      Rails.logger.debug "===============FINISHED ARCHIVING OF USER: #{id} ==============================="
    end
  end

  def rank
    rank = Leaderboards.influencers.rank(id) unless Rails.env.test?      
    rank || 0
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  def remove_influencer_from_redis
    Leaderboards.influencers.drop_influencer(id) unless Rails.env.test?
  end
end
