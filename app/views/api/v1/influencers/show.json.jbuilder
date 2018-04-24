json.data do
  json.extract! @influencer, :id, :info, :contact_info, :profile_percentage_complete, :score, :rank
end
json.status_code 1
