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
  let(:user) { User.first_or_create!(email: 'user@example.com', password: 'password') }

  it 'post has title' do
    post = Post.new(
      title: '',
      body: 'Post body',
      user_id: user.id,
    )
    expect(post).to_not be_valid
    post.title = 'Post title'
    expect(post).to be_valid
  end

  it 'post title minimum length ' do
    post = Post.new(
      title: '12',
      body: 'Post body',
      user_id: user.id,
    )
    expect(post).to_not be_valid
    post.title = '123'
    expect(post).to be_valid
  end

  it 'post title maximum length ' do
    hundred_fifty_char_string = 'AFpSfFbfvOEbsmbSrqWxhsVBEoKfCeVqNemaHDivUtWjH7NaRytkYBc1CMbGilO9qU15WT1NNeMFvsYqWV7RsV7iHoPoWiNkMA4t0d8r47LEhQ9o6zUUEEOWQSRqTRywMzyEqq758WRJgimd220RAC'
    post = Post.new(
      title: hundred_fifty_char_string,
      body: 'Post body',
      user_id: user.id,
    )
    expect(post).to be_valid
    post.title = hundred_fifty_char_string + '1'
    expect(post).to_not be_valid
  end

  it 'post has body' do
    post = Post.new(
      title: 'Post title',
      body: '',
      user_id: user.id,
    )
    expect(post).to_not be_valid
    post.body = 'Post body'
    expect(post).to be_valid
  end

  it 'post body minimum length' do
    post = Post.new(
      title: 'Post title',
      body: '12',
      user_id: user.id,
    )
    expect(post).to_not be_valid
    post.body = '123'
    expect(post).to be_valid
  end

  it 'post body maximum length' do
    five_hundred_char_string = 'NVO3NvUnYD4YUrWrBrBcxtu7N8IuLFocZfXH7mdVzZrJvB4wBfyCmBTc2Wo2nhzrwBxPwGA6d3ToAx6eWmFfsw3jrF31yaRrg0hX4VqTYMjYC4TBuMpvM4cvny44pMTzfasYSYquVQSv9Y7XwGCiYoFqBof8er99YnUZ1XRGSOdB3U60RnbBBOpJWR7MHnIWQi9DdtMLgHLVwDFscAEDETcgdrSPEJWp0MWn8iYNOUoBfhlt8nHteJGEnGIZ3bCZv6it49XIzs3SqvdnWoEoT7I9Ix1hBGYU8eNzQCna1wVe3P2pJ1hLLo3PuNS9CUbGSrTgpcBM6tUFcfTTQ4aTcYfFn8pVBBFY2plfn7i1i92KSUVrWuiazJRme7RBJxWlvVVVRFL30WIqjQIRAAFRO2HmasXEHWa9sXjc9OFIe2ipUbjP9zA1d9er7efxgDs4m6nxEtCC058ceDmxSB2ZotN3VKCev2qVbhSyRV8sFLNc1gT0lAE8'
    post = Post.new(
      title: 'Post title',
      body: five_hundred_char_string,
      user_id: user.id,
    )
    expect(post).to be_valid
    post.body = five_hundred_char_string + '1'
    expect(post).to_not be_valid
  end
end
