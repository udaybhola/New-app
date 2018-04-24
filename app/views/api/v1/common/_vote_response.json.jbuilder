json.data do
  json.extract! @party_and_support_info, :party_name, :candidature, :candidate_vote_count, :supported_user_info, :vote_percentage
end
json.status_code 1
