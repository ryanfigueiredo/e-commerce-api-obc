FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "123456789" }
    password_confirmation { "123456789" }
    profile { [:admin].sample }
  end
end
