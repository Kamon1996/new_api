json.(current_user, :id, :name, :sername, :email, :created_at, :updated_at)
json.posts current_user.posts do |post|
  json.(post, :id, :title, :body, :created_at, :updated_at)
end
json.comments current_user.comments do |comment|
  json.(comment, :id, :body, :created_at, :updated_at)
end