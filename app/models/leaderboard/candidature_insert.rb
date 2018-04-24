module Leaderboard
  module CandidatureInsert
    extend ActiveSupport::Concern

    def register_candidature_voted(candidate_vote)
      candidature = candidate_vote.candidature
      register_candidature_score(candidature)
      register_candidature_score(candidate_vote.previous_vote.candidature) if candidate_vote.previous_vote
    end

    def register_candidature_score(candidature)
      if candidature.constituency.is_assembly?
        register_candidature_score_assembly(candidature)
      elsif candidature.constituency.is_parliament?
        register_candidature_score_parliament(candidature)
      end
    end

    def register_candidature_score_parliament(candidature)
      key = parliament_key(candidature.election)
      redis.zadd key, candidature.total_votes, candidature.id

      const_key = constituency_parliament_key(
        candidature.constituency.country_state,
        candidature.constituency,
        candidature.election
      )
      redis.zadd const_key, candidature.total_votes, candidature.id unless const_key.blank?
    end

    def register_candidature_score_assembly(candidature)
      key = assembly_key(candidature.constituency.country_state,
                         candidature.election)
      redis.zadd key, candidature.total_votes, candidature.id

      const_key = constituency_assembly_key(
        candidature.constituency.country_state,
        candidature.constituency,
        candidature.election
      )
      redis.zadd const_key, candidature.total_votes, candidature.id
    end

    def register_candidature_created(candidature)
      register_candidature_score(candidature)
    end

    def reset_candidates_scores(candidature_ids)
      candidature_ids.each do |candidature_id|
        register_candidature_score(::Candidature.find(candidature_id))
      end
    end
  end
end
