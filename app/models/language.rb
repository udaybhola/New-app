class Language < ApplicationRecord
  ALL = %w[हिन्दी ਪੰਜਾਬੀ English বাংলা తెలుగు मराठी தமிழ் ಕನ್ನಡ ગુજરાતી മലയാളം].freeze
  ALL_KEYS = %w[Hindi Punjabi English Bengali Telugu Marathi Tamil Kannada Gujarati Malayalam].freeze
  validates :name, presence: true, uniqueness: true

  default_scope { order('name ASC') }

  scope :available, -> { where(availability: true) }

  def self.seed
    Language::ALL.each_with_index do |item, index|
      Language.find_or_create_by(name: item, value: ALL_KEYS[index])
    end
  end
end
