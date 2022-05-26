# frozen_string_literal: true

json.id comment.id
json.post_id comment.post_id
json.body comment.body
json.created_at comment.created_at
json.updated_at comment.updated_at
json.author do
  json.partial! 'parsials/author', locals: { author: comment.user }
end
