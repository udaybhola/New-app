p "creating religions.."
religions = %w[Muslim Hindu Sikh Christian]
religions.each do |religion|
  Religion.find_or_create_by!(name: religion)
end
