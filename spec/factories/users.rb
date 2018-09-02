
FactoryGirl.define do
  factory :user do
    transient     { region_name 'London' }
    transient     { group_name 'Central' }
    transient     { route_name 'NCN 1' }

    name          { Faker::Name.name }
    email         { Faker::Internet.email }
    password      { Faker::Internet.password }
    region        { Region.find_by(name: region_name) || FactoryGirl.create(:region, name: region_name) }


    factory :guest do
      role 'guest'
    end

    # TODO - after create is not working
    factory :volunteer do
      role 'volunteer'
      after(:create) do |user|
        user.groups        { [ Route.find_by(name: group_name) || FactoryGirl.create(:group, name: group_name) ] }
        user.routes        { [ Route.find_by(name: route_name) || FactoryGirl.create(:route, name: route_name) ] }
      end
    end

    factory :ranger do
      role 'ranger'
      after(:create) do |user|
        user.groups        { [ Route.find_by(name: group_name) || FactoryGirl.create(:group, name: group_name) ] }
        user.routes        { [ Route.find_by(name: route_name) || FactoryGirl.create(:route, name: route_name) ] }
      end
    end

    factory :coordinator do
      role 'coordinator'
      after(:create) do |user|
        user.groups        { [ Route.find_by(name: group_name) || FactoryGirl.create(:group, name: group_name) ] }
        user.routes        { [ Route.find_by(name: route_name) || FactoryGirl.create(:route, name: route_name) ] }
      end
    end

    factory :staff do
      role 'staff'
      after(:create) do |user|
        user.groups        { [ Route.find_by(name: group_name) || FactoryGirl.create(:group, name: group_name) ] }
      end
    end
  end
end

