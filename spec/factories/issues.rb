
FactoryGirl.define do
  factory :issue do
    lat             51.52029
    lng             -0.10359
    route           { FactoryGirl.build(:route) }
    group           { FactoryGirl.build(:group) }
    category        { FactoryGirl.build(:category) }
    problem         { FactoryGirl.build(:problem) }
    user            { FactoryGirl.build(:ranger) }
    title          'some title'
    url            ''
  end
end
