FactoryBot.define do
  factory :player do
    name { Faker::Sports::Football.player }
    position { "MF" }
    number { Faker::Number.between(from: 1, to: 99) }
    image { Faker::Avatar.image }
    yellow_card { 0 }
    red_card { 0 }
    appearances { 1 }
    market_value { Faker::Number.number(digits: 7) }
    salary { Faker::Number.number(digits: 6) }
  end
end
