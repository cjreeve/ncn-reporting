
FactoryGirl.define do
  factory :group do
    transient { region_name 'central' }
    name            'central'
    region          { Region.find_by(name: region_name) || FactoryGirl.create(:region, name: region_name) }
  end
end
