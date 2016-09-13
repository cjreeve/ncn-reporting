
FactoryGirl.define do
  factory :group do
    name            'central'
    region          { FactoryGirl.create(:region) }
  end
end
