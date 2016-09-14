
FactoryGirl.define do
  factory :category do
    transient do
      category_name 'Signage'
    end

    name do
      Category.find_by(name: category_name) || FactoryGirl.create(:category, name: category_name)
    end
  end
end
