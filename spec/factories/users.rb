
FactoryGirl.define do
  factory :user do
    transient     { region_name 'central' }

    name          { Faker::Name.name }
    email         { Faker::Internet.email }
    password      { Faker::Internet.password }
    region        { Region.find_by(name: region_name) || FactoryGirl.create(:region, name: region_name) }

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

