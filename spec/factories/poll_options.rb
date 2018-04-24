FactoryBot.define do
  factory :poll_option do
    poll
    answer 'I like it'
    poll_votes_count 0
  end
end
