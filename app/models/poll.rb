class Poll < Post
  has_many :poll_options, dependent: :destroy
  validates :question, presence: true

  before_save :generate_slug

  def generate_slug
    self.slug = question.parameterize
  end

  def has_user_voted?(user_id = nil)
    return false if user_id.blank?
    PollVote.where(poll_id: id, user_id: user_id).valid.count > 0
  end
end
