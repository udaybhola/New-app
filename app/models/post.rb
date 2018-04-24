class Post < ApplicationRecord
  paginates_per 100

  include Rails.application.routes.url_helpers
  include Activable
  include ScoreCalculator
  include Likeable
  include Flaggable
  include PushNotifiable

  belongs_to :user, optional: true
  belongs_to :region, polymorphic: true, optional: true
  belongs_to :category, optional: true
  has_many :poll_options, foreign_key: 'poll_id', dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  before_destroy :delete_from_influx
  accepts_nested_attributes_for :attachments
  accepts_nested_attributes_for :poll_options,
                                allow_destroy: true,
                                reject_if: lambda { |attributes|
                                  attributes['answer'].blank?
                                }
  before_save :generate_slug

  scope :admin, -> { where(user_id: nil).order('created_at DESC') }
  scope :featured, -> { where(user_id: nil, archived: false, show_on_dashboard: false).order('position ASC') }
  scope :dashboard, -> { where(user_id: nil, archived: false, show_on_dashboard: true).order('position ASC') }
  scope :archived, -> { Post.unscoped.where(archived: true).order('position ASC') }
  scope :user, -> { where("user_id IS NOT NULL").order('created_at DESC') }

  scope :national, -> { where(region_id: nil).order('created_at DESC') }
  scope :country_state, -> { where(region_type: 'CountryState').order('created_at DESC') }
  scope :constituency, -> { where(region_type: 'Constituency').order('created_at DESC') }
  scope :state, -> (state_id) { where(region_id: CountryState.find(state_id).constituencies.map(&:id)) }

  default_scope { where(archived: false) }

  def self.types
    %w(issue poll)
  end

  def generate_slug
    if title.length > 1
      self.slug = title.parameterize
    elsif question.length > 1
      self.slug = question.parameterize
    end
  end

  def name
    case type
    when 'Issue'
      title
    when 'Poll'
      question
    end
  end

  def admin?
    user_id.blank?
  end

  def poll?
    type == 'Poll'
  end

  def issue?
    type == 'Issue'
  end

  def national_level?
    admin? && region_type.blank?
  end

  def state_level?
    admin? && region_type == 'CountryState'
  end

  def constituency_level?
    admin? && region_type == 'Constituency'
  end

  def user_level?
    !admin? && region_type == 'Constituency'
  end

  def score
    calculate_post_value(comments_count, likes_count)
  end

  def liked_by_user?(user_id)
    if user_id.nil?
      false
    else
      likes.where(user_id: user_id).count.positive?
    end
  end

  def is_admin?
    user_id.nil?
  end

  def is_featured?
    user_id.nil? && !archived && !show_on_dashboard
  end

  def is_archived?
    archived
  end

  def related_activity_ids
    poll_vote_ids = poll_options.map(&:poll_votes).reduce(:+).map(&:id) if poll?
    poll_vote_ids = poll_vote_ids || []
    comments_ids = comments.ids
    likes_ids = likes.ids
    related_activities = Activity.unscoped.where(activable_id: poll_vote_ids + comments_ids + likes_ids + [id])
    all_activity_ids = related_activities.ids
    Rails.logger.debug "Activity ids to recalibrate: #{all_activity_ids}"
    all_activity_ids
  end

  def archive_related_activities
    if user_level?
      all_activity_ids = related_activity_ids
      Activity.unscoped.where(id: all_activity_ids).update_all(archived: true) unless all_activity_ids.empty?
      uniq_user_ids = Activity.unscoped.where(id: all_activity_ids).map(&:user_id).uniq
      Leaderboards.influencers.reset_influencer_scores(uniq_user_ids) unless Rails.env.test? && uniq_user_ids.empty?
    end
  end

  def unarchive_related_activities
    if user_level?
      all_activity_ids = related_activity_ids
      Activity.unscoped.where(id: all_activity_ids).update_all(archived: false) unless all_activity_ids.empty?
      uniq_user_ids = Activity.unscoped.where(id: all_activity_ids).map(&:user_id).uniq
      Leaderboards.influencers.reset_influencer_scores(uniq_user_ids) unless Rails.env.test? && uniq_user_ids.empty?
    end
  end

  def archive
    self.archived = true
    archive_related_activities
    save
  end

  def unarchive
    self.archived = false
    unarchive_related_activities
    save
  end

  def share_description
    if poll?
      "Answer your area's top polls or start a new poll on the Neta App."
    elsif issue?
      "Report and read about top issues in your constituency on the Neta App"
    else
      ""
    end
  end

  def is_anonymous?
    anonymous
  end

  def image_url
    if attachments.empty?
      ""
    else
      attachments.first.media_url
    end
  end

  def generate_share_link(force = false)
    if national_level?
      url = if type == "Poll" 
              poll_url(self)
            elsif type == "Issue"
              issue_url(self)
            end
    elsif state_level?
      url = if type == "Poll" 
              state_poll_url(region, self)
            elsif type == "Issue"
              state_issue_url(region, self)
            end
    elsif constituency_level?
      url = if type == "Poll" 
              constituency_poll_url(region, self)
            elsif type == "Issue"
              constituency_issue_url(region, self)
            end
    elsif user_level?
       url = if type == "Poll" 
              constituency_poll_url(region, self)
            elsif type == "Issue"
              constituency_issue_url(region, self)
            end
    end
    
    if !firebase_url.blank? && !force
      return [url, firebase_url]
    else
      firebase_dynamic_link = Firebase::DynamicLink.new(
        title: name,
        description: share_description,
        image_url: image_url,
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
    return true if Influx::EntityInstances.post_scoring_measurement
                                          .delete_post_measurement_points(id)
    errors.add :base, "Cannot delete post without removing from Influx"
    throw(:abort)
  end

  def likes_count
    likes.count
  end

  def comments_count
    comments.count
  end
end
