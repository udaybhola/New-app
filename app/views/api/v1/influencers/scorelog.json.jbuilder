json.data do
  json.offset @all_activities.offset
  json.limit @all_activities.limit
  json.activities @all_activities.activities, partial: 'api/v1/common/activity', as: :activity
end
json.status_code 1
