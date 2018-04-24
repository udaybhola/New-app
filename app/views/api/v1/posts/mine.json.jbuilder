json.data do
  json.offset @posts_activities.offset
  json.limit @posts_activities.limit
  json.activities @posts_activities.activities, partial: 'api/v1/common/activity', as: :activity
end
json.status_code 1
