class Problem < ActiveRecord::Base
  has_many :categories, through: :category_problem_selections
end
