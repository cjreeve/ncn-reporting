
FactoryGirl.define do
  factory :issue do
    transient { route_name 'NCN 1' }
    transient { group_name 'central' }
    transient { category_name 'Signage' }
    transient { problem_name 'Missing' }
    transient { user_name Faker::Name.name }
    transient { user_role :volunteer }
    transient { label_names ['volunteer'] }
    transient { region_name 'central' }
    transient { group_region_name nil }
    transient { administrative_area_name "London Borough of Islington" }
    transient { user_region_name nil }

    lat                     51.52029
    lng                     -0.10359
    route                   { Route.find_by(name: route_name) || FactoryGirl.create(:route, name: route_name) }
    group                   { Group.find_by(name: group_name) || FactoryGirl.build(:group, name: group_name, region_name: (group_region_name || region_name)) }
    category                { Category.find_by(name: category_name) || FactoryGirl.build(:category, name: category_name) }
    problem                 { Problem.find_by(name: problem_name) || FactoryGirl.build(:problem, name: problem_name) }
    user                    { User.find_by(name: user_name) || FactoryGirl.build(user_role, name: user_name, region_name: (user_region_name || region_name)) }
    title                   'some title'
    url                     ''
    administrative_area do
      AdministrativeArea.find_by(name: administrative_area_name) ||
      FactoryGirl.create(:administrative_area, name: administrative_area_name, group_name: group_name)
    end

    labels do
      label_names.collect do |label_name|
        Label.find_by(name: label_name) || FactoryGirl.create(:label, name: label_name)
      end
    end
  end
end
