json.array! candidates_data do |candidate|
  json.candidature_id candidate.candidature_id
  json.candidate_id candidate.candidate_id
  json.candidate_name candidate.candidate_name
  json.declared_candidate candidate.declared_candidate
  json.party_abbreviation candidate.party_abbreviation
  json.party candidate.party
  json.candidate_profile_pic do
    if !candidate.candidate_profile_pic.file.nil? && candidate.candidate_profile_pic.respond_to?(:full_public_id)
      json.cloudinary do
        json.public_id candidate.candidate_profile_pic.file.public_id
      end
    end
  end
  json.party_image do
    if !candidate.party_image.file.nil? && candidate.party_image.respond_to?(:full_public_id)
      json.cloudinary do
        json.public_id candidate.party_image.file.public_id
      end
    end
  end
  json.votes candidate.votes
  json.percentage candidate.percentage
  json.is_party_leader candidate.is_party_leader
  json.is_voted_by_me candidate.is_voted_by_me
  unless candidate.party_and_support_info.nil?
    json.party_and_support_info candidate.party_and_support_info
  end
  json.candidature_constituency_id candidate.candidature_constituency_id
  json.has_cover candidate.has_cover_image
  json.label candidate.label
  json.constituency_name candidate.constituency_name
end
