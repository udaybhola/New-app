module ApiResponseModels
  module Api
    module V1
      class PartyLeadersData
        attr_accessor :position, :position_hierarchy, :candidate_info

        def initialize(position, position_hierarchy, candidate_info)
          @position = position
          @position_hierarchy = position_hierarchy
          @candidate_info = candidate_info
        end

        def self.construct_candidate_info(candidate)
          candidate_info = CustomOstruct.new
          candidate_info.candidate_id = candidate.id
          candidate_info.candidate_name = candidate.profile.name
          candidate_info.candidate_profile_pic = candidate.profile.profile_pic
          candidate_info
        end

        def self.fetch_from_active_record(party)
          party_leaders = party.party_leaders
          all_party_leaders = []
          party_leaders.each do |leader|
            candidate_info = construct_candidate_info(leader.candidate)
            all_party_leaders << new(leader.party_leader_position.name, leader.party_leader_position.position_hierarchy, candidate_info)
          end
          all_party_leaders
        end

        def self.fetch_data(party)
          fetch_from_active_record(party)
        end
      end
    end
  end
end
