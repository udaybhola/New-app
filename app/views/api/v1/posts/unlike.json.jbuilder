json.data do
  json.partial! 'api/v1/common/like', like: @like
end
json.status_code 1
