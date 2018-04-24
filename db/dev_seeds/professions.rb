p "creating professions.."
professions = ["Private", "Public"]
professions.each do |profession|
  Profession.find_or_create_by(name: profession)
end
