FactoryBot.define do
  factory :category do
    sequence(:name) { |number| "Category-#{number}" }
  end
end
