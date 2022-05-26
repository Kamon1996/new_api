# frozen_string_literal: true

json.id post.id
json.title post.title
json.body post.body
json.created_at post.created_at
json.updated_at post.updated_at
json.author do
  json.partial! 'parsials/author', locals: { author: post.user }
end
json.comments post.comments do |comment|
  json.partial! 'parsials/comment', locals: { comment: comment }
end
