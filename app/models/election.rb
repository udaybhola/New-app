class Election < ApplicationRecord
  paginates_per 100

  belongs_to :country_state, optional: true
  has_many :candidatures, dependent: :destroy
  has_many :candidates, through: :candidatures

  has_many :bulk_files, dependent: :destroy

  store_accessor :data,
                 :votes_received

  KIND_ASSEMBLY = "assembly".freeze
  KIND_PARLIAMENT = "parliamentary".freeze
  KIND_LOCAL = "local".freeze

  KINDS = [KIND_ASSEMBLY, KIND_PARLIAMENT, KIND_LOCAL].freeze

  default_scope { order('created_at DESC') }

  scope :assembly, -> { where(kind: KIND_ASSEMBLY) }
  scope :parliamentary, -> { where(kind: KIND_PARLIAMENT) }

  def title
    "#{country_state.try(:name)} #{kind} elections (#{starts_at})"
  end
end
