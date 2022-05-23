FactoryBot.define do
  factory :post do
    title { Faker::FunnyName.name }
    body { Faker::Hacker.say_something_smart }
    user   
  end
end