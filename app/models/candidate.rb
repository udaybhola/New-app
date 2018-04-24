class Candidate < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_many :candidatures, dependent: :destroy
  has_many :elections, through: :candidatures
  belongs_to :label, optional: true
  validates_uniqueness_of :link_phone_number, allow_blank: true

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :candidatures

  def name
    profile ? profile.name : phone_number
  end

  def current_candidature
    return nil if candidatures.nil?

    #give preference to assembly candidature
    assembly_candidatures = candidatures.joins(:election).where.not(election_id: CountryState.current_parliamentary_election.id).order("elections.starts_at desc")

    return assembly_candidatures.first if assembly_candidatures.count > 0

    #candidature of current election
    parliament_candidatures = candidatures.where(election_id: CountryState.current_parliamentary_election.id)
    
    return parliament_candidatures.first if parliament_candidatures.count > 0 

    return nil
  end

  def logged_in? 
    linked? && !profile.user.nil?
  end

  def linked?
    should_link_with_phone_number && !link_phone_number.blank?
  end
end
