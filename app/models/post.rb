class Post < ApplicationRecord
  
  belongs_to :user
  has_many :comments
  
  validates :title, presence: true, length: {minimum:3, maximum:150}
  validates :body, presence: true, length: {minimum:3, maximum:500}

end
