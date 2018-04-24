FactoryBot.define do
  factory :poll do
    user
    category
    question 'What do you think contributed to win of bjp?'
    after(:create) do |poll|
      create(:poll_option, poll: poll, answer: 'Patidars shifting Allegience')
      create(:poll_option, poll: poll, answer: 'Modis campaign')
      create(:poll_option, poll: poll, answer: 'Congress leaders unnecessary comments')
    end
  end
end
