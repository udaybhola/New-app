p "creating castes.."
castes = %w[Jatt Khap Kamma Khsatriya Harijan]
castes.each do |caste|
  Caste.find_or_create_by!(name: caste)
end
