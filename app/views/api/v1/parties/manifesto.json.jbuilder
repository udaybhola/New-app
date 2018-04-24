json.data do
  json.partial! 'api/v1/common/manifesto', locals: { manifesto: @manifesto, pages: @pages }
end
