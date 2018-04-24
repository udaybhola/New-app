json.data do
  json.partial! 'api/v1/common/candidatures', locals: { candidates_data: @candidates }
end
json.status_code 1
