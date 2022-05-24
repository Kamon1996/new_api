# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:post) { build(:post) }

  it 'should not validate post with too short title (minimum 3)' do
    post.title = '12'
    expect(post).to_not be_valid
    post.title = '123'
    expect(post).to be_valid
  end

  it 'should not validate post with too long title (maximum 150)' do
    hundred_fifty_char_string = 'a' * 150
    post.title = hundred_fifty_char_string
    expect(post).to be_valid
    post.title += '1'
    expect(post).to_not be_valid
  end

  it 'should not validate post with too short body (minimum 3)' do
    post.body = '12'
    expect(post).to_not be_valid
    post.body = '123'
    expect(post).to be_valid
  end

  it 'should not validate post with too long body (maximum 500)' do
    five_hundred_char_string = '1' * 500
    post.body = five_hundred_char_string
    expect(post).to be_valid
    post.body += '1'
    expect(post).to_not be_valid
  end
end
