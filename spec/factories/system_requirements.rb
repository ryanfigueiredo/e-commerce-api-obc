FactoryBot.define do
  factory :system_requirement do
    sequence(:name) { |number| "Basic-#{number}" }
    operational_system { Faker::Computer.os }
    storage { "500gb" }
    processor { "AMD Ryzen 7" }
    memory { "16gb" }
    video_board { "Geforce GTX 1660 TI" }
  end
end
