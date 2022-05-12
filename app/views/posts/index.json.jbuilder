json.posts @posts do |post|
  json.(post, :id, :title, :body, :created_at, :updated_at)
  json.comments post.comments do |comment|
    json.id comment.id
    json.body comment.body
    json.created_at comment.created_at
    json.updated_at comment.updated_at
    json.author do
      json.id comment.user.id
      json.name comment.user.name
      json.sername comment.user.sername
    end
  end
  json.author do
    json.id post.user.id
    json.name post.user.name
    json.sername post.user.sername
  end
end



