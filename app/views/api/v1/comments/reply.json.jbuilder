json.data do
  json.partial! 'comment', comment: @comment
end
json.status_code 1
