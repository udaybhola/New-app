web: bundle exec rails server -p $PORT
all_resque: bundle exec rails resque:work QUEUE='*'
critical_resque: bundle exec rails resque:work QUEUE=critical
priority_resque: bundle exec rails resque:work QUEUE=critical,high,medium,default,low
leaderboard_update_current_parliamentary_elections: bundle exec rake leaderboard:update_current_parliamentary_elections
leaderboard_update_current_assembly_elections: bundle exec rake leaderboard:update_current_assembly_elections
leaderboard_update_national_and_state_seats_and_votes: bundle exec rake leaderboard:update_national_and_state_seats_and_votes
leaderboard_update_update_influencers: bundle exec rake leaderboard:update_influencers
