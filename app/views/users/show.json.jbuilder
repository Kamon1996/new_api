# frozen_string_literal: true

json.id @user.id
json.name @user.name
json.sername @user.sername
json.email @user.email
json.created_at @user.created_at
json.updated_at @user.updated_at

json.posts @user.posts do |post|
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
