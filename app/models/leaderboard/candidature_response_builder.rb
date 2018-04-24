module Leaderboard
  module CandidatureResponseBuilder
    extend ActiveSupport::Concern

    def build_top_candidates_response(data, options = {})
      user_id = options[:user_id]
      ac_id = options[:ac_id]
      state_id = options[:state_id]
      pc_id = options[:pc_id]
      election_id = options[:election_id]

      return [] if data.empty?
      vote_hash = data
      candidatures = ::Candidature.where(
        id: vote_hash.keys
      )
      if ac_id.nil? && state_id.nil? && pc_id.nil?
        is_national_level = true
      elsif state_id.nil? && pc_id.nil?
        # assembly
        total_votes = ::Candidature.where(election_id: election_id, constituency_id: ac_id)
                                   .map(&:total_votes)
                                   .reduce(:+)
      elsif state_id.nil? && ac_id.nil?
        # parliament
        total_votes = ::Candidature.where(election_id: election_id, constituency_id: pc_id)
                                   .map(&:total_votes)
                                   .reduce(:+)
      elsif pc_id.nil? && ac_id.nil?
        is_state_level = true
      end

      candidates = []
      candidatures.each do |candidature|
        candidate = candidature.candidate
        party = candidature.party
        vote_count = vote_hash[candidature.id]
        is_voted_by_me = candidature.is_voted_by_user(user_id)
        party_and_support_info = if is_voted_by_me
                                   user = User.find(user_id)
                                   ApiResponseModels::Api::V1::CandidateProfileData.construct_party_info(user.profile, candidature.candidate, candidature.constituency, user, candidature)
                                 end
        label = candidate.label.nil? ? nil : { name: candidate.label.name, color: candidate.label.color }
        if is_national_level || is_state_level
          total_votes = ::Candidature.where(election_id: candidature.election.id, constituency_id: candidature.constituency.id)
                                     .map(&:total_votes)
                                     .reduce(:+)
        end
        party_info = {
          name: party.name,
          image: party.party_image_obj,
          abbreviation: party.abbreviation
        }

        candidates << ApiResponseModels::Api::V1::CandidatesData.new(
          candidature.id, candidate.id, candidate.profile.name,
          candidature.declared, party.abbreviation,
          candidate.profile.profile_pic, party.image,
          vote_count,
          total_votes.zero? ? 0 : (vote_count.to_f / total_votes.to_f) * 100.to_f,
          false, is_voted_by_me, party_and_support_info, candidature.constituency_id, !candidate.profile.cover_photo_obj.nil?, label, party_info, candidature.constituency.name
        )
      end
      candidates.sort_by! { |item| -item.votes }
    end
  end
end
