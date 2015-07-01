class CategoryProblemSelection < ActiveRecord::Base
  belongs_to :category
  belongs_to :problem
end
