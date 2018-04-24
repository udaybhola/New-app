class Comment < ApplicationRecord
  include Activable
  include Likeable
  include Flaggable
  include PushNotifiable

  belongs_to :user
  belongs_to :post, counter_cache: true

  belongs_to :parent, class_name: 'Comment', optional: true, touch: true, counter_cache: true
  has_many :children, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy

  validates :text, presence: true
  validate :allow_only_one_level
  include ScoreCalculator
  default_scope { where(archived: false) }

  def allow_only_one_level
    errors.add(:parent_id, "trying to add a comment for a reply") if parent_id != nil && !Comment.find(parent_id).parent_id.nil?
  end

  def score
    calcualate_comment_value(comments_count, likes_count)
  end

  def liked_by_user?(user_id)
    if user_id.nil?
      false
    else
      likes.where(user_id: user_id).count.positive?
    end
  end
end
