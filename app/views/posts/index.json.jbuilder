# frozen_string_literal: true

json.posts @posts do |post|
  json.partial! 'parsials/post', locals: { post: post }
end
