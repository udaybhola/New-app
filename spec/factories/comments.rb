FactoryBot.define do
  factory :comment do
    user
    post
    text 'This is an important issue that we need to seriously consider fixing.'
  end
end
