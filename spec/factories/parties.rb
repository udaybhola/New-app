FactoryBot.define do
  factory :party do
    name "Indian National Congress"
    sequence(:abbreviation) { |n| "INC#{n}" }
  end
end
