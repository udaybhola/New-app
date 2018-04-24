class ActivityJob < ApplicationJob
  queue_as do
    activable = arguments.first
    case activable[:type]
    when 'Issue'
      'low'
    when 'Poll'
      'low'
    when 'PollVote'
      'high'
    when 'Comment'
      'high'
    when 'Like'
      'high'
    when 'CandidateVote'
      'critical'
    when 'PartyMembership'
      'low'
    else
      'low'
    end
  end

  def perform(activable)
    Rails.logger.debug "Start: Need to perform activity job #{activable}"
    case activable[:type]
    when 'Candidature'
      candidature = Candidature.find(activable[:id])
      activity = candidature.create_activity(meta_action: 'Created Candidature',
                                             meta_object: candidature.candidate.profile.try(:name),
                                             score: 0)
      Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
    when 'User'
      user = User.find(activable[:id])
      activity = user.create_activity(user: user,
                                      activable: user,
                                      meta_action: 'registered with',
                                      meta_object: 'Neta',
                                      author: user.profile.try(:name),
                                      title: 'Registration',
                                      score: 0)
      Leaderboards.influencers.register_influencer_score(user) unless Rails.env.test?
      Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
    when 'Issue'
      issue = Issue.find(activable[:id])
      author = issue.admin? ? 'admin-user' : issue.user.profile.try(:name)
      activity = issue.create_activity(user: issue.user,
                                       meta_action: 'created an',
                                       meta_object: 'Issue',
                                       author: author,
                                       title: issue.title,
                                       score: 10)
      Leaderboards.influencers.register_influencer_score(issue.user) unless Rails.env.test?
      Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
    when 'Poll'
      poll = Poll.find(activable[:id])
      author = poll.admin? ? 'admin-user' : poll.user.profile.try(:name)
      activity = poll.create_activity(user: poll.user,
                                      meta_action: 'created a',
                                      meta_object: 'Poll',
                                      author: author,
                                      title: poll.title,
                                      score: 8)
      Leaderboards.influencers.register_influencer_score(poll.user) unless Rails.env.test?
      Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
    when 'PollVote'
      poll_vote = PollVote.find(activable[:id])
      score = poll_vote.poll.is_admin? ? 5 : 2
      has_already_voted_for_same_poll = PollVote.where(
        user_id: poll_vote.user_id,
        poll_id: poll_vote.poll_id
      ).where.not(id: poll_vote.id).count > 0
      activity = poll_vote.create_activity(user: poll_vote.user,
                                           meta_action: 'voted for',
                                           meta_object: 'Poll',
                                           title: poll_vote.poll.question,
                                           score: has_already_voted_for_same_poll ? 0 : score)
      Leaderboards.influencers.register_influencer_score(poll_vote.user) unless Rails.env.test?
      Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
      ## owner of the post will also receive points
      post = poll_vote.poll
      if !post.is_admin? && poll_vote.user.id != post.user.id
        activity = poll_vote.create_activity(user: post.user,
                                             meta_action: 'received a vote on',
                                             meta_object: post.class.name,
                                             title: post.name,
                                             score: has_already_voted_for_same_poll ? 0 : 2)
        Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
        Leaderboards.influencers.register_influencer_score(post.user) unless Rails.env.test?
      end

    when 'Comment'
      comment = Comment.find(activable[:id])
      activity = comment.create_activity(user: comment.user,
                                         meta_action: 'commented on',
                                         meta_object: comment.post.class.name,
                                         title: comment.post.name,
                                         score: 5)
      Leaderboards.influencers.register_influencer_score(comment.user) unless Rails.env.test?
      Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?

      ## owner of the post will also receive points
      if !comment.post.is_admin? && comment.user.id != comment.post.user.id
        activity = comment.create_activity(user: comment.post.user,
                                           meta_action: 'received a comment on',
                                           meta_object: comment.post.class.name,
                                           title: comment.post.name,
                                           score: 5)
        Leaderboards.influencers.register_influencer_score(comment.post.user) unless Rails.env.test?
        Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
      end

    when 'Like'
      like = Like.find(activable[:id])
      activity = like.create_activity(
        user: like.user,
        meta_action: 'liked',
        meta_object: like.likeable.class.name,
        title: (
               case like.likeable.class.name
               when 'Poll' || 'Issue'
                 like.likeable.name
               when 'Comment'
                 like.likeable.text
               end
        ),
        score: 1
      )
      Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
      ## owner of the post will also receive points
      if like.likeable.class.name == 'Poll' || like.likeable.class.name == 'Issue'
        post = like.likeable
        if !post.is_admin? && like.user.id != post.user.id
          activity = like.create_activity(user: post.user,
                                          meta_action: 'received a like on',
                                          meta_object: post.class.name,
                                          title: post.name,
                                          score: 5)
          Leaderboards.influencers.register_influencer_score(post.user) unless Rails.env.test?
          Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
        end
      end
      Leaderboards.influencers.register_influencer_score(like.user) unless Rails.env.test?
    when 'CandidateVote'
      vote = CandidateVote.find(activable[:id])
      is_vote_valid = vote.is_valid

      if is_vote_valid
        is_new_vote = vote.previous_vote.nil?
        activity = vote.create_activity(user: vote.user,
                                        meta_action: is_new_vote ? 'voted for' : 'changed vote to',
                                        meta_object: vote.candidature.candidate.profile.try(:name),
                                        score:  is_new_vote ? 10 : 0)
      else
        activity = vote.create_activity(user: vote.user,
                                        meta_action: 'Canceled vote to',
                                        meta_object: vote.candidature.candidate.profile.try(:name),
                                        score:  -10)
      end
      Leaderboards.influencers.register_influencer_score(vote.user) unless Rails.env.test?
      Influx::EntityInstances.seeder_activities.seed_activity(activity) unless Rails.env.test?
    when 'PartyMembership'
      membership = PartyMembership.find(activable[:id])
      membership.create_activity(user: membership.user,
                                 meta_action: 'became a member of',
                                 meta_object: membership.party.title,
                                 score: 50)
      Leaderboards.influencers.register_influencer_score(membership.user) unless Rails.env.test?
    end
    Rails.logger.debug "End: Performed activity job #{activable}"
  end
end
