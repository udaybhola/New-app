FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:firebase_user_id) { |n| n }
    password 'new-password86'
    password_confirmation 'new-password86'
    name 'testuser-#{n}'
  end
end
