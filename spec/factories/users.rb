FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password              { 'abc123' }
    password_confirmation { password }
    name                  { Faker::Name.name }
    profile               { Faker::Lorem.sentence }
    occupation            { Faker::Company.name }
    position              { Faker::Job.title }
  end
end
