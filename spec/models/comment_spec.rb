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
  let(:comment) { build(:comment) }

  it 'should not validate comment with too short body (minimum 3)' do
    comment.body = '12'
    expect(comment).to_not be_valid
    comment.body = '123'
    expect(comment).to be_valid
  end

  it 'should not validate comment with too long body (maximum 150)' do
    one_hundred_fifty_char_length = 'a' * 150
    comment.body = one_hundred_fifty_char_length
    expect(comment).to be_valid
    comment.body += '1'
    expect(comment).to_not be_valid
  end
end
