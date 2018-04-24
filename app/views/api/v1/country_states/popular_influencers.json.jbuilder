json.data do
  json.partial! 'api/v1/common/influencers', locals: { influencers_data: @influencers }
end
json.status_code 1
