FactoryBot.define do
  factory :party_leader_position do
    name { "Gemini " + ('a'..'z').to_a.shuffle.join }
    description { "Pollux " + ('a'..'z').to_a.shuffle.join }
    sequence(:position_hierarchy) { |n| n }
  end
end
