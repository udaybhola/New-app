FactoryBot.define do
  factory :issue do
    user
    category
    title 'Repair of Durga Mata Mandir Road'
    description 'Here is a bunch of text for the description'
    anonymous false
  end
end
