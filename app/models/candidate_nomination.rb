class CandidateNomination < ApplicationRecord
  validates :name, :age, presence: true
  validates :age, numericality: true
  validates :election_kind, inclusion: { in: %w[assembly parliament],
                                         message: "%{value} is not a valid election kind, valid are assembly and parliament" }
  belongs_to :party
  belongs_to :country_state
  belongs_to :assembly, class_name: 'Constituency', foreign_key: "assembly_id"
  belongs_to :parliament, class_name: 'Constituency', foreign_key: "parliament_id"

  store_accessor :meta,
                 :news_pr_links
end
