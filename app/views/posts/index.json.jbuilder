# frozen_string_literal: true

json.posts @posts do |post|
  json.partial! 'partials/post', locals: { post: post }
end
