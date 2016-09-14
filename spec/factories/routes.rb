
FactoryGirl.define do
  factory :route do
    transient do
      route_name 'NCN 1'
    end

    name do
      Route.find_by(name: route_name) || FactoryGirl.create(:route, name: route_name)
    end
  end
end
