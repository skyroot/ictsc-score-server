require 'sinatra/crypt_helpers'

FactoryBot.define do
  factory :member do
    sequence(:name) {|n| "member_#{n}" }
    sequence(:login) {|n| "member_login_#{n}" }
    password { 'test' }
    role { build(:role, :nologin) }

    trait :admin do
      password { 'admin' }
      association :role, factory: %i[role admin]
    end

    trait :writer do
      association :role, factory: %i[role writer]
    end

    trait :participant do
      association :role, factory: %i[role participant]
      team
    end

    trait :viewer do
      association :role, factory: %i[role viewer]
    end
  end
end
