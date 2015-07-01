class Category < ActiveRecord::Base
  has_many :category_problem_selections
  has_many :problems, through: :category_problem_selections
end
