FactoryBot.define do
  factory :prototype do
    title      { Faker::App.name }
    catch_copy { Faker::Lorem.sentence }
    concept    { Faker::Lorem.paragraph }
    association :user

    after(:build) do |prototype|
      prototype.image.attach(io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')), filename: 'test_image.png')
    end
  end
end
