
FactoryBot.define do
  factory :administrative_area do
    transient { group_name 'central' }

    name              "London Borough of Islington"
    short_name        "Islington"
    group             { Group.find_by(name: group_name) || FactoryBot.create(:group, name: group_name) }
  end
end
