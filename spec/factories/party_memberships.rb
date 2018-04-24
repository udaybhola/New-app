FactoryBot.define do
  factory :party_membership do
    user
    party
    constituency
    description { Faker::Lorem.sentences }
  end
end
