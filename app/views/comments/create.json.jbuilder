json.id @comment.id
json.post_id @comment.post.id
json.body @comment.body
json.created_at @comment.created_at
json.updated_at @comment.updated_at

json.author do
  json.id @comment.user.id
  json.name @comment.user.name
  json.sername @comment.user.sername
end
