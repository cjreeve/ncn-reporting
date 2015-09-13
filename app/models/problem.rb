class Problem < ActiveRecord::Base
  has_many :categories, through: :category_problem_selections

  validates :name, length: { in: 2..20, message: '- the problem summary should be between 2 and 20 characters'}
end
