
FactoryGirl.define do
  factory :problem do
    default_priority   1

    transient do
      problem_name 'Missing'
    end

    name do
      Problem.find_by(name: problem_name) || FactoryGirl.create(:problem, name: problem_name)
    end
  end
end
