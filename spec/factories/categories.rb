FactoryBot.define do
  factory :category do
    name 'Environmental Issues'
    image File.open("#{Rails.root}/spec/images/image.png")
    slug 'environmental-issue'
  end
end
