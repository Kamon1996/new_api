# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
require 'faker'

10.times do |_p|
  post = Post.new
  post.title = Faker::Hipster.sentence(word_count: 3)
  post.body = Faker::Hipster.paragraph(sentence_count: 2, supplemental: true)
  post.user_id = User.first.id
  post.save
end
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
