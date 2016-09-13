
FactoryGirl.define do
  factory :user do
    name          { Faker::Name.name }
    email         { Faker::Internet.email }
    password      { Faker::Internet.password }
    region        { FactoryGirl.create(:region) }

    factory :guest do
      role 'guest'
    end

    factory :volunteer do
      role 'volunteer'
    end

    factory :ranger do
      role 'ranger'
    end
  end
end

