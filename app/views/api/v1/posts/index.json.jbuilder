json.data do
  json.partial! 'api/v1/common/posts', locals: { data: @data }
end
json.status_code 1
