json.data do
  json.array! @translations do |translation|
    json.key translation[0]
    json.value translation[1].strip
  end
end
json.status_code 1
