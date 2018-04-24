class Issue < Post
  validates :title, presence: true
  validates :description, presence: true

  before_save :generate_slug

  def generate_slug
    self.slug = title.parameterize
  end
end
