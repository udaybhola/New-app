p "creating categories.."
categories = ["Environmental Issues", "Infrastructure", "Health Related Issues", "Educational Issues", "Financial Issues", "National Issues"]
categories.each do |category_name|
  p "creating category: #{category_name}"
  category = Category.find_or_create_by!(name: category_name)
  unless category.image.url
    category.image = File.open("#{Rails.root}/db/dev_seeds/images/categories/#{category_name.parameterize}.png")
    category.save!
  end
end
