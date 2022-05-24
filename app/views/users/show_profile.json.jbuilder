# frozen_string_literal: true

json.user do
  json.id current_user.id
  json.name current_user.name
  json.sername current_user.sername
  json.email current_user.email
  json.created_at current_user.created_at
  json.updated_at current_user.updated_at

  json.comments current_user.comments do |comment|
    json.id comment.id
    json.body comment.body
    json.created_at comment.created_at
    json.updated_at comment.updated_at
  end

  json.posts current_user.posts do |post|
    json.id post.id
    json.title post.title
    json.body post.body
    json.created_at post.created_at
    json.updated_at post.updated_at
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
end
