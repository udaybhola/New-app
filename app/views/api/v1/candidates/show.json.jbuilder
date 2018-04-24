json.data do
  json.extract! @candidate, :id, :party_and_support_info, :info, :contact_info
end
json.status_code 1
