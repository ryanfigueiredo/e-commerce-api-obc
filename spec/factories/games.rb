FactoryBot.define do
  factory :game do
    mode { [:pvp, :pve, :both].sample }
    release_date { "2020-11-07 12:06:48" }
    developer { Faker::Company.name }
    system_requirement
  end
end
