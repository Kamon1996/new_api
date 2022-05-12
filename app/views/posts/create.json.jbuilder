
  json.id @post.id
  json.title @post.title
  json.body @post.body
  json.created_at @post.created_at
  json.updated_at @post.updated_at
  json.author do
    json.id @post.user.id
    json.name @post.user.name
    json.sername @post.user.sername
  end
