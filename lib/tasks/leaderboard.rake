namespace :leaderboard do
  desc "Leaderboard management tasks"

  desc "Seed current parliamentary election leaderboard"
  task update_current_parliamentary_elections: [:environment] do
    puts "Seeding candidatures"
    Leaderboards.candidatures.seed_current_parliamentary_elections
  end

  desc "Seed current assembly elections of all states"
  task update_current_assembly_elections: [:environment] do
    puts "Seeding candidatures"
    Leaderboards.candidatures.seed_current_assembly_elections
  end

  desc "Seed parties"
  task update_national_and_state_seats_and_votes: [:environment] do
    puts "Scale up image maker"
    HerokuClient.scale_up_image_maker
    puts "Updating national and state seats and votes"
    Leaderboards.parties.update_national_and_state_seats_and_votes
    puts "Scale down image maker"
    HerokuClient.scale_down_image_maker
  end

  desc "Seed influencer"
  task update_influencers: [:environment] do
    puts "Updating national and state seats and votes"
    Leaderboards.influencers.seed_all
  end

  desc "Drop current parliamentary election leaderboard"
  task drop_current_parliamentary_elections: [:environment] do
    puts "Dropping candidatures"
    Leaderboards.candidatures.drop_current_parliamentary_elections
  end
  desc "Drop current assembly election leaderboard"
  task drop_current_assembly_elections: [:environment] do
    puts "Dropping candidatures"
    Leaderboards.candidatures.drop_current_assembly_elections
  end
end
