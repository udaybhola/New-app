json.extract! comment, :id, :text, :score, :comments_count, :likes_count, :created_at
json.author do
  json.name comment.user.profile.name
  json.image comment.user.profile.profile_pic
end
