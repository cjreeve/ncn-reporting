
FactoryGirl.define do
  factory :region do
    transient do
      region_name 'central'
    end

    name do
      Region.find_by(name: region_name) || FactoryGirl.create(:region, name: region_name)
    end
  end
end
