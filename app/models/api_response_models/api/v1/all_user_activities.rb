module ApiResponseModels
  module Api
    module V1
      class AllUserActivities < PostActivities
        def self.construct_candidate_vote_activity(candidate_vote)
          candidate_vote_obj = CustomOstruct.new
          candidate_vote_obj.party_name = candidate_vote.candidature.party
          candidate_vote_obj.party_image = candidate_vote.candidature.party.image
          candidate_vote_obj
        end

        def self.construct_party_membership_activity(membership)
          party_membership_obj = CustomOstruct.new
          party_membership_obj.party_name = membership.party.title
          party_membership_obj.party_image = membership.party.image
          party_membership_obj
        end

        def self.parse_candidate_vote_activity(activity)
          activity_id = activity.id
          action = activity.meta["meta_action"]
          resource = activity.meta["meta_object"]
          voted_poll_option_id = nil
          candidate_vote = CandidateVote.find(activity.activable_id)

          activity_obj = CustomOstruct.new
          activity_obj = set_activity_object_default_attrs(activity_obj, activity_id, action, resource, voted_poll_option_id, activity.score, activity.created_at, "candidate_vote")
          activity_obj.data = construct_candidate_vote_activity(candidate_vote)
          activity_obj
        end

        def self.parse_party_membership_activity(activity)
          activity_id = activity.id
          action = activity.meta["meta_action"]
          resource = activity.meta["meta_object"]
          voted_poll_option_id = nil
          membership = PartyMembership.find(activity.activable_id)

          activity_obj = CustomOstruct.new
          activity_obj = set_activity_object_default_attrs(activity_obj, activity_id, action, resource, voted_poll_option_id, activity.score, activity.created_at, "party_membership_requested")
          activity_obj.data = construct_party_membership_activity(membership)
          activity_obj
        end

        def self.parse_activities(user_id, activities)
          all_activities = []
          post_ids = []
          activities.each do |activity|
            if %w[Post Poll Issue PollVote].include?(activity.activable_type)
              new_activity, add = parse_post_activity(user_id, activity, post_ids, all_activities)
              all_activities << new_activity if add
            elsif %w[Comment Like].include?(activity.activable_type)
              new_activity, add = parse_post_activity(user_id, activity, post_ids, all_activities)
              all_activities << new_activity if add
            elsif activity.activable_type == 'CandidateVote'
              all_activities << parse_candidate_vote_activity(activity)
            elsif activity.activable_type == 'PartyMembership'
              all_activities << parse_party_membership_activity(activity)
            end
          end
          all_activities
        end

        def self.fetch_data(user_id, all_activities, offset, limit)
          activities = all_activities
          all_activities = parse_activities(user_id, activities)
          data = CustomOstruct.new
          data.offset = offset
          data.limit = limit
          data.activities = all_activities.slice(offset, limit)
          data
        end
      end
    end
  end
end
