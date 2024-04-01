FactoryBot.define do
  factory :ride do
    start_address { "789 Oak St" }
    destination_address { "101 Pine St" }
    association :driver
  end
end