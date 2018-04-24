module ApiResponseModels
  module Api
    module V1
      class CandidatesData
        attr_accessor :candidature_id, :candidate_id, :candidate_name, :declared_candidate, :party_abbreviation, :candidate_profile_pic, :party_image, :votes, :percentage, :is_party_leader, :is_voted_by_me, :party_and_support_info, :candidature_constituency_id, :has_cover_image, :label, :party, :constituency_name

        def initialize(candidature_id, candidate_id, candidate_name, declared_candidate, party_abbreviation, candidate_profile_pic, party_image, votes, percentage, is_party_leader, is_voted_by_me, party_and_support_info = nil, candidature_constituency_id = nil, has_cover_image = nil, label = nil, party = {}, constituency_name = nil)
          @candidature_id = candidature_id
          @candidate_id = candidate_id
          @candidate_name = candidate_name
          @declared_candidate = declared_candidate
          @party_abbreviation = party_abbreviation
          @party = party
          @candidate_profile_pic = candidate_profile_pic
          @party_image = party_image
          @votes = votes
          @percentage = percentage
          @is_party_leader = is_party_leader
          @is_voted_by_me = is_voted_by_me
          @party_and_support_info = party_and_support_info
          @candidature_constituency_id = candidature_constituency_id
          @has_cover_image = has_cover_image
          @label = label
          @constituency_name = constituency_name
        end

        def self.fetch_from_active_record(user_id, constituency_id, query_param)
          constituency = Constituency.find(constituency_id)
          candidatures = if query_param.nil?
                           Candidature.joins(:election).where(constituency: constituency).order("elections.starts_at desc")
                         else
                           Candidature.joins(:election, candidate: [profile: :user]).where("users.name LIKE ? ", "%#{query_param}%").where(constituency: constituency).order("elections.starts_at desc")
                         end
          candidates = []
          total_votes = candidatures.map(&:total_votes).reduce(:+)
          candidatures.each do |candidature|
            candidate = candidature.candidate
            party = candidature.party
            vote_count = candidature.total_votes
            # TODO: determine is_party_leader
            is_voted_by_me = candidature.is_voted_by_user(user_id)
            party_and_support_info = if is_voted_by_me
                                       user = User.find(user_id)
                                       ApiResponseModels::Api::V1::CandidateProfileData.construct_party_info(user.profile, candidature.candidate, candidature.constituency, user)
                                     end
            label = candidate.label.nil? ? nil : { name: candidate.label.name, color: candidate.label.color }
            party_info = {
              name: party.name,
              image: party.party_image_obj,
              abbreviation: party.abbreviation
            }
            candidates << new(candidature.id, candidate.id, candidate.profile.name, candidature.declared, party.abbreviation, candidate.profile.profile_pic, party.image, vote_count, total_votes.zero? ? 0 : (vote_count / total_votes) * 100, false, is_voted_by_me, party_and_support_info, candidature.constituency_id, !candidate.profile.cover_photo_obj.nil?, label, party_info, candidature.constituency.name)
          end
          candidates
        end

        def self.fetch_data(user_id, constituency_id, sort_by = "votes", query_param = nil)
          if Rails.env.test?
            candidates = fetch_from_active_record(user_id, constituency_id, query_param)
            case sort_by
            when "votes_asc"
              candidates.sort_by(&:votes)
            when "party"
              candidates.sort_by(&:party_abbreviation)
            else
              candidates.sort_by(&:votes).reverse
            end
          else
            if constituency_id.nil?
              data = Influx::Series.popular_candidatures_nation(CountryState.current_parliamentary_election.id, 100)
            else
              const = Constituency.find(constituency_id)
              return [] unless const
              data = if const.is_assembly?
                       Influx::Series.popular_candidatures_ac(const.current_election.id, constituency_id)
                     else
                       Influx::Series.popular_candidatures_state(const.country_state.current_assembly_election.id, const.country_state.id)
                     end
            end

            return [] if data.empty?
            vote_hash = data.first["values"].map { |item| [item["candidature_id"], item["vote_count"]] }.to_h
            candidatures = Candidature.where(id: data.first["values"].map { |item| item["candidature_id"] })
            total_votes = candidatures.map(&:total_votes).reduce(:+)
            candidates = []
            candidatures.each do |candidature|
              candidate = candidature.candidate
              party = candidature.party
              vote_count = vote_hash[candidature.id]
              is_voted_by_me = candidature.is_voted_by_user(user_id)
              # TODO: determine is_party_leader
              party_and_support_info = if is_voted_by_me
                                         user = User.find(user_id)
                                         ApiResponseModels::Api::V1::CandidateProfileData.construct_party_info(user.profile, candidature.candidate, candidature.constituency, user)
                                       end
              label = candidate.label.nil? ? nil : { name: candidate.label.name, color: candidate.label.color }
              party_info = {
                name: party.name,
                image: party.party_image_obj,
                abbreviation: party.abbreviation
              }
              candidates << new(candidature.id, candidate.id, candidate.profile.name, candidature.declared, party.abbreviation, candidate.profile.profile_pic, party.image, vote_count, total_votes.zero? ? 0 : (vote_count.to_f / total_votes.to_f) * 100.to_f, false, is_voted_by_me, party_and_support_info, candidature.constituency_id, !candidate.profile.cover_photo_obj.nil?, label, party_info, candidature.constituency.name)
            end
            candidates.sort_by! { |item| -item.votes }
          end
        end
      end
    end
  end
end
