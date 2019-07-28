class Category < ApplicationRecord
  has_many :category_problem_selections
  has_many :problems, through: :category_problem_selections
  has_many :issues
end
