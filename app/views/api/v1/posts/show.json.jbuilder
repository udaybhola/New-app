json.data do
  json.partial! 'api/v1/common/post', post: @post
end
json.status_code 1
