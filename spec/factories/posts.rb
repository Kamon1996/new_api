FactoryBot.define do
  factory :post do
    title { Faker::FunnyName.name }
    body { Faker::Hacker.say_something_smart }
    user
  end
end

def make_few_posts(user: nil, posts_count: 5)
  posts_count.times do
    create(:post, user: user)
  end
end