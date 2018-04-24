module ApiResponseModels
  module Api
    module V1
      class InfluencerProfileData
        include ProfileBuilder
        attr_accessor :id, :info, :contact_info, :leader_supporting_info, :profile_percentage_complete, :score, :rank
        # info - age, gender, religion, caste, education, profession, income, assets, liabilities, criminal_cases
        # contact_info - phone, email, website, facebook, twitter

        def initialize(id, info, contact_info, leader_supporting_info = nil, score = nil, profile_percentage_complete = nil, rank = nil)
          @id = id
          @info = info
          @contact_info = contact_info
          @leader_supporting_info = leader_supporting_info
          @score = score
          @profile_percentage_complete = profile_percentage_complete
          @rank = rank
        end

        def self.fetch_from_active_record(user, current_user_id)
          profile = user.profile
          info = construct_info(profile)
          contact_info = construct_contact_info(profile)
          score = user.total_score
          if !current_user_id.nil? && user.id == current_user_id
            profile_percentage_complete = calculate_percentage_completeness(info, contact_info)
          end
          new(user.id, info, contact_info, nil, score, profile_percentage_complete, user.rank)
        end

        def self.fetch_data(user, current_user_id = nil)
          fetch_from_active_record(user, current_user_id)
        end
      end
    end
  end
end
