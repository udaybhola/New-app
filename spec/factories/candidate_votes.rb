FactoryBot.define do
  factory :candidate_vote do
    user
    candidature
    is_valid true
  end
end
