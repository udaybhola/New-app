module ApiResponseModels
  module Api
    module V1
      class CandidateProfileData
        include ProfileBuilder
        attr_accessor :id, :party_and_support_info, :info, :contact_info
        # info - age, gender, religion, caste, education, profession, income, assets, liabilities, criminal_cases
        # contact_info - phone, email, website, facebook, twitter

        def initialize(id, info, contact_info, party_and_support_info = nil)
          @id = id
          @info = info
          @contact_info = contact_info
          @party_and_support_info = party_and_support_info
        end

        def self.construct_party_info(_profile, candidate, constituency, user = nil, _candidature = nil)
          party_and_support_info = CustomOstruct.new
          current_election = constituency.is_assembly? ? constituency.country_state.current_assembly_election : CountryState.current_parliamentary_election
          candidature = Candidature.where(constituency: constituency, candidate: candidate, election: current_election).first
          party_and_support_info.party_name = candidature.party.title
          party_and_support_info.party_profile_pic = !candidature.party.image.file.nil? && candidature.party.image.respond_to?(:full_public_id) ? { cloudinary: { public_id: candidature.party.image.file.public_id } } : nil
          candidate_vote_count = candidature.total_votes
          party_and_support_info.candidature = { candidature_id: candidature.id, constituency_id: constituency.id, constituency_name: constituency.name, candidate_name: candidature.candidate.profile.name }
          party_and_support_info.candidate_vote_count = candidate_vote_count
          total_votes = candidature.constituency.total_votes(candidature.election)
          party_and_support_info.vote_percentage = total_votes.zero? ? 0 : ((candidate_vote_count.to_f / total_votes.to_f) * 100).to_f
          user_vote = CandidateVote.find_by(user: user, election: candidature.election, is_valid: true)
          party_and_support_info.supported_user_info = {}
          if user_vote
            user_vote_candidature = user_vote.candidature
            party_and_support_info.supported_user_info = {
              id: user_vote_candidature.id,
              party: user_vote_candidature.party.abbreviation,
              constituency: user_vote_candidature.constituency.name,
              candidate_name: user_vote_candidature.candidate.profile.name,
              vote_date: user_vote.created_at.to_date,
              profile_pic: !user_vote_candidature.candidate.profile.profile_pic.file.nil? && user_vote_candidature.candidate.profile.profile_pic.respond_to?(:full_public_id) ? { cloudinary: { public_id: user_vote_candidature.candidate.profile.profile_pic.file.public_id } } : nil,
              party_profile_pic: !user_vote_candidature.party.image.file.nil? && user_vote_candidature.party.image.respond_to?(:full_public_id) ? { cloudinary: { public_id: user_vote_candidature.party.image.file.public_id } } : nil
            }
          end
          party_and_support_info
        end

        def self.fetch_from_active_record(candidate_id, constituency, user)
          candidate = Candidate.find(candidate_id)
          profile = candidate.profile
          info = construct_info(profile)
          info.label = { name: candidate.label.name, color: candidate.label.color } unless candidate.label.nil?
          contact_info = construct_contact_info(profile)
          party_and_support_info = construct_party_info(profile, candidate, constituency, user)
          new(candidate_id, info, contact_info, party_and_support_info)
        end

        def self.fetch_data(candidate_id, constituency, user)
          fetch_from_active_record(candidate_id, constituency, user)
        end
      end
    end
  end
end
