FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.sentence }
    association :prototype
    association :user
  end
end
