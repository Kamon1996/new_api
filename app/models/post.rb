class Post < ApplicationRecord
  
  validates :title, presence: true, length: {minimum:3, maximum:150}
  validates :body, presence: true, length: {minimum:3, maximum:500}
  belongs_to :user

  has_many :comments
end
