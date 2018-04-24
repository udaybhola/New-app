require 'rails_helper'

RSpec.describe Influx::SeedFromActivities, type: :model, ci: !ENV["CI_NAME"].blank? do
  before(:each) do
    root_db = Influx::EntityInstances.root_db
    root_db.destroy!
    root_db.create!
    expect(root_db.exists?).to be_truthy
    rp = Influx::EntityInstances.rp
    rp.create_all_rps!
    expect(rp.does_last_3_hrs_exists?).to be_truthy
    expect(rp.does_last_24_hrs_exists?).to be_truthy
    expect(rp.does_last_week_exists?).to be_truthy
    expect(rp.does_last_month_exists?).to be_truthy
    expect(rp.does_since_the_beginning_exists?).to be_truthy
  end

  after(:each) do
    root_db = Influx::EntityInstances.root_db
    root_db.destroy!
    expect(root_db.exists?).to be_falsey
    Influx::EntityInstances.reset
  end

  it "should create user with zero score on creation" do
    const = create(:constituency, kind: 'assembly')
    5.times do
      create(:user, constituency: const)
      sleep 1.second
    end
    seeder = Influx::EntityInstances.seeder_activities
    seeder.seed
    measurement = Influx::EntityInstances.influencer_scoring_measurement

    result = measurement.db
                        .client
                        .query %(
                          select #{measurement.all_tags_query_string}
                          from #{measurement.autogen_db}
                          where "score" = 0
                        )

    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    expect(result.first.values[2].count).to eq 5

    result = measurement.db
                        .client
                        .query %(
                          select #{measurement.all_tags_query_string}
                          from #{measurement.autogen_db}
                        )

    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    expect(result.first.values[2].count).to eq 5
  end

  it "should create candidature with zero score on creation" do
    election = create(:election, starts_at: Time.now - 100.days, ends_at: Time.now + 100.days)
    const = create(:constituency, kind: 'assembly')

    party1 = create(:party)
    party2 = create(:party)
    party3 = create(:party)

    candidature1 = create(:candidature, election: election, party: party1, constituency: const)
    sleep 1.second
    candidature2 = create(:candidature, election: election, party: party2, constituency: const)
    sleep 1.second
    candidature3 = create(:candidature, election: election, party: party3, constituency: const)
    sleep 1.second

    seeder = Influx::EntityInstances.seeder_activities
    seeder.seed

    measurement = Influx::EntityInstances.candidature_scoring_measurement

    # candidate created should be 3 items
    result = measurement.db
                        .client
                        .query %(
                          select #{measurement.all_tags_query_string}
                          from #{measurement.autogen_db}
                          where "score" = 0
                        )

    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    expect(result.first.values[2].count).to eq 3

    result = measurement.db
                        .client
                        .query %(
                          select #{measurement.all_tags_query_string}
                          from #{measurement.autogen_db}
                        )

    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    expect(result.first.values[2].count).to eq 3
  end

  it "should change candidature score and influencer score on voting" do
    parl_const = create(:constituency)
    const = create(:constituency, parent: parl_const)

    election = create(:election, country_state: const.country_state, starts_at: Time.now - 100.days, ends_at: Time.now + 100.days)

    party1 = create(:party)
    party2 = create(:party)
    party3 = create(:party)

    candidature1 = create(:candidature, election: election, party: party1, constituency: const)
    candidature1.candidate.profile = create(:profile)
    candidature1.candidate.save!
    sleep 1.second
    candidature2 = create(:candidature, election: election, party: party2, constituency: const)
    candidature2.candidate.profile = create(:profile)
    candidature2.candidate.save!
    sleep 1.second
    candidature3 = create(:candidature, election: election, party: party3, constituency: const)
    candidature3.candidate.profile = create(:profile)
    candidature3.candidate.save!
    sleep 1.second

    user1 = create(:user, constituency: const)
    user1.profile = create(:profile)
    user1.save!
    user2 = create(:user, constituency: const)
    user2.profile = create(:profile)
    user2.save!
    user3 = create(:user, constituency: const)
    user3.profile = create(:profile)
    user3.save!
    user4 = create(:user, constituency: const)
    user4.profile = create(:profile)
    user4.save!

    vote1 = create(:candidate_vote, candidature: candidature1, user: user1)
    sleep 1.second
    create(:candidate_vote, candidature: candidature1, user: user2)
    sleep 1.second
    user3_vote = create(:candidate_vote, candidature: candidature2, user: user3)
    sleep 1.second
    create(:candidate_vote, candidature: candidature2, user: user1, previous_vote: vote1)

    expect(candidature1.candidate_votes.count).to eq 2
    expect(candidature1.candidate_votes.valid.count).to eq 1

    expect(candidature2.candidate_votes.count).to eq 2
    expect(candidature2.candidate_votes.valid.count).to eq 2

    expect(candidature3.candidate_votes.count).to eq 0
    expect(candidature3.candidate_votes.valid.count).to eq 0

    # cancel vote
    sleep 1.second
    earlier_valid_candidature_votes = candidature2.candidate_votes.valid.count
    cancel_vote = user3_vote.invalidate_vote
    expect(candidature2.candidate_votes.valid.count).to eq earlier_valid_candidature_votes - 1

    seeder = Influx::EntityInstances.seeder_activities
    seeder.seed

    measurement = Influx::EntityInstances.candidature_scoring_measurement

    # 4 votes casted
    result = measurement.db
                        .client
                        .query %(
                          select #{measurement.all_tags_query_string}
                          from #{measurement.autogen_db}
                          where "score" = 1
                        )

    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    no_of_items_with_score_1 = 4
    expect(result.first.values[2].count).to eq no_of_items_with_score_1

    result = measurement.db
                        .client
                        .query %(
                          select #{measurement.all_tags_query_string}
                          from #{measurement.autogen_db}
                          where "score" = -1
                        )

    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    # one for change of voting, another for cancelation of voting
    no_of_items_with_score_minus_one = 2
    expect(result.first.values[2].count).to eq no_of_items_with_score_minus_one

    influencer_measurement = Influx::EntityInstances.influencer_scoring_measurement
    # user 1 count should be 3
    result = influencer_measurement.db
                                   .client
                                   .query %(
                          select #{influencer_measurement.all_tags_query_string}
                          from #{influencer_measurement.autogen_db}
                          where "user_id" = '#{user1.id}'
                        )
    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    expect(result.first.values[2].count).to eq user1.activities.count

    # user 2 count should be 2
    result = influencer_measurement.db
                                   .client
                                   .query %(
                          select #{influencer_measurement.all_tags_query_string}
                          from #{influencer_measurement.autogen_db}
                          where "user_id" = '#{user2.id}'
                        )
    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    expect(result.first.values[2].count).to eq user2.activities.count

    # user 3 count should be 2
    result = influencer_measurement.db
                                   .client
                                   .query %(
                          select #{influencer_measurement.all_tags_query_string}
                          from #{influencer_measurement.autogen_db}
                          where "user_id" = '#{user3.id}'
                        )

    expect(result.count).to eq 1
    expect(result.first.values.count).to eq 3
    expect(result.first.values[2].count).to eq user3.activities.count

    results = influencer_measurement.user_scores
    scores = {}
    results.each do |result|
      scores[result.values[1]["user_id"]] = result.values[2][0]["score"]
    end
    expect(scores[user1.id]).to eq 10
    expect(scores[user2.id]).to eq 10
    expect(scores[user3.id]).to eq 0
    expect(scores[user4.id]).to eq 0

    # top candidates
    measurement = Influx::EntityInstances.candidature_scoring_measurement

    result = measurement.top_candidates_of_ac(
      ac_id: const.id,
      election_id: election.id,
      top: 10,
      user_id: user1.id
    )
    expect(result).not_to be_empty
    expect(result.select { |item| item.candidate_id == candidature2.candidate_id }.first.votes).to eq(candidature2.candidate_votes.valid.count)

    result = measurement.top_candidates_of_state(
      state_id: const.country_state.id,
      election_id: election.id,
      top: 10,
      user_id: user1.id
    )
    expect(result).not_to be_empty

    result = measurement.top_candidates_of_nation(
      election_id: election.id,
      top: 10,
      user_id: user1.id
    )
    expect(result).to be_empty

    result = measurement.top_parties_of_constituency_ac(
      ac_id: const.id,
      election_id: election.id,
      top: 10
    )

    expect(result).not_to be_empty

    result = measurement.top_parties_of_constituency_state(
      state_id: const.country_state.id,
      election_id: election.id,
      top: 10
    )

    expect(result).not_to be_blank

    result = measurement.top_parties_of_constituency_nation(
      election_id: election.id,
      top: 10
    )

    expect(result).to be_blank

    # top influencers
    measurement = Influx::EntityInstances.influencer_scoring_measurement
    result = measurement.popular_influencers_ac(
      ac_id: const.id,
      top: 10
    )
    expect(result).not_to be_empty
    expect(result.size).to eq 4

    result = measurement.popular_influencers_state(
      state_id: const.country_state.id,
      top: 10
    )
    expect(result).not_to be_empty
    expect(result.size).to eq 4

    result = measurement.popular_influencers_nation(
      state_id: const.country_state.id,
      top: 10
    )
    expect(result).not_to be_empty
    expect(result.size).to eq 4

    result = measurement.popular_influencers_nation(
      state_id: const.country_state.id
    )
    expect(result).not_to be_empty
    expect(result.size).to eq 4
  end

  it "should change influencer measurement when a new post is created" do
    parl_const = create(:constituency)
    const = create(:constituency, parent: parl_const)

    user1 = create(:user, constituency: const)
    user1.profile = create(:profile)
    user1.save!
    sleep 1.second
    user2 = create(:user, constituency: const)
    user2.profile = create(:profile)
    user2.save!
    sleep 1.second
    user3 = create(:user, constituency: const)
    user3.profile = create(:profile)
    user3.save!
    sleep 1.second
    user4 = create(:user, constituency: const)
    user4.profile = create(:profile)
    user4.save!
    sleep 1.second

    # create issue
    issue = create(:issue, title: 'Pollution in Delhi', region: const, user: user1)
    sleep 1.second
    poll = create(:poll, title: 'Pollution in Delhi', region: const, user: user2)

    poll_option1 = create(:poll_option, poll: poll)
    poll_option2 = create(:poll_option, poll: poll)
    poll_option3 = create(:poll_option, poll: poll)

    poll_vote1 = create(:poll_vote, user: user1, poll_option: poll_option1)
    sleep 1.second
    poll_vote2 = create(:poll_vote, user: user2, poll_option: poll_option2)
    sleep 1.second
    poll_vote3 = create(:poll_vote, user: user3, poll_option: poll_option2)
    sleep 1.second
    poll_vote4 = create(:poll_vote, user: user4, poll_option: poll_option3)

    # comments
    comment1 = issue.comments.create!(user: user3, text: "Hey")
    sleep 1.second
    comment2 = issue.comments.create!(user: user3, text: "there")
    sleep 1.second

    # likes
    like1 = issue.like(user4)
    sleep 1.second

    like2 = poll.like(user3)
    sleep 1.second

    seeder = Influx::EntityInstances.seeder_activities
    seeder.seed

    measurement = Influx::EntityInstances.influencer_scoring_measurement
    result = measurement.popular_influencers_ac(
      ac_id: const.id,
      top: 10
    )
    expect(result).not_to be_empty
    item = result.select { |item| item.influencer_id == user1.id }.first
    expect(item.score).to eq 27

    item = result.select { |item| item.influencer_id == user2.id }.first
    expect(item.score).to eq 21

    item = result.select { |item| item.influencer_id == user3.id }.first
    expect(item.score).to eq 13

    item = result.select { |item| item.influencer_id == user4.id }.first
    expect(item.score).to eq 3

    expect(result.first.influencer_id).to eq user1.id
    expect(result.second.influencer_id).to eq user2.id
    expect(result.third.influencer_id).to eq user3.id
    expect(result.fourth.influencer_id).to eq user4.id

    measurement = Influx::EntityInstances.post_scoring_measurement
    result = measurement.trending(
      constituency_id: const.id,
      top: 10
    )
    expect(result.no_of_issues).to eq 1
    expect(result.no_of_polls).to eq 1

    measurement = Influx::EntityInstances.poll_vote_scoring_measurement
    result = measurement.polling_results(poll.id)
    expect(result).not_to be_empty

    # poll resolutions
    result = measurement.poll_stats(
      poll_id: poll.id,
      resolution: 'last_24_hours'
    )
    expect(result).not_to be_empty
  end
end
