
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

    factory :volunteer do
      role 'volunteer'
      groups        { [ Route.find_by(name: group_name) || FactoryGirl.create(:group, name: group_name) ] }
      routes        { [ Route.find_by(name: route_name) || FactoryGirl.create(:route, name: route_name) ] }
    end

    factory :ranger do
      role 'ranger'
      groups        { [ Route.find_by(name: group_name) || FactoryGirl.create(:group, name: group_name) ] }
      routes        { [ Route.find_by(name: route_name) || FactoryGirl.create(:route, name: route_name) ] }
    end

    factory :coordinator do
      role 'coordinator'
      groups        { [ Route.find_by(name: group_name) || FactoryGirl.create(:group, name: group_name) ] }
      routes        { [ Route.find_by(name: route_name) || FactoryGirl.create(:route, name: route_name) ] }
    end

    factory :staff do
      role 'staff'
      groups        { [ Route.find_by(name: group_name) || FactoryGirl.create(:group, name: group_name) ] }
    end
  end
end

