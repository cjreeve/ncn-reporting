
FactoryBot.define do
  factory :group do
    transient { region_name 'London' }
    name            'central'
    region          { Region.find_by(name: region_name) || FactoryBot.create(:region, name: region_name) }
  end
end
