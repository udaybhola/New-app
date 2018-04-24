p "creating education.."
education_levels = ["Graduate", "Post Graduate", "12th Pass", "10th Pass"]
education_levels.each do |education|
  Education.find_or_create_by(name: education)
end
