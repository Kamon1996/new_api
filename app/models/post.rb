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
class Post < ApplicationRecord
  
  belongs_to :user
  has_many :comments, dependent: :destroy
  
  validates :title, presence: true, length: {minimum:3, maximum:150}
  validates :body, presence: true, length: {minimum:3, maximum:500}

end
