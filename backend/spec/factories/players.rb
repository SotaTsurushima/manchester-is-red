FactoryBot.define do
  factory :player do
    name { Faker::Sports::Football.player }
    position { "MF" }
    number { Faker::Number.between(from: 1, to: 99) }
    image { Faker::Avatar.image }
    goals { 0 }
    assists { 0 }
    yellow_card { 0 }
    red_card { 0 }
    appearances { 1 }
    market_value { Faker::Number.number(digits: 7) }
    salary { Faker::Number.number(digits: 6) }

    # 特定のプレイヤー用のトレイト
    trait :bruno_fernandes do
      name { "Bruno Fernandes" }
      number { 18 }
      position { "MF" }
    end

    trait :benjamin_sesko do
      name { "Benjamin Šeško" }
      number { 9 }
      position { "FW" }
    end

    # 統計データ付きのトレイト
    trait :with_stats do
      appearances { 25 }
      goals { 3 }
      assists { 7 }
      yellow_card { 2 }
      red_card { 0 }
    end
  end
end
