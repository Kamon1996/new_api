# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :integer
#  user_id    :integer
#
# Indexes
#
#  index_comments_on_post_id  (post_id)
#  index_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  post_id  (post_id => posts.id)
#  user_id  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { User.first_or_create!(email: 'user@example.com', password: 'password') }
  let(:post) { Post.first_or_create!(title: 'post title', body: 'post body', user_id: user.id) }

  it 'body minimum length' do
    comment = Comment.new(
      body: '12',
      post_id: post.id,
      user_id: user.id,
    )
    expect(comment).to_not be_valid
    comment.body = '123'
    expect(comment).to be_valid
  end

  it 'body maximum length' do
    fifty_char_string = 'K7dmKrFc6TxDm5nf2vXKJdp52zxTe5aff4UpFW63B44CrahUlv'
    comment = Comment.new(
      body: fifty_char_string,
      post_id: post.id,
      user_id: user.id,
    )
    expect(comment).to be_valid
    comment.body = fifty_char_string + '1'
    expect(comment).to_not be_valid
  end
end
