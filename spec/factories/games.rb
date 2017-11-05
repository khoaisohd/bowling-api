FactoryGirl.define do
  factory :game do
    name { Faker::Lorem.word }
    usernames {['username'].to_json}
  end
end
