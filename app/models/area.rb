class Area < ActiveRecord::Base
  
  has_many :issues

  has_many :user_managed_area_selections
  has_many :users, through: :user_managed_area_selections

  has_many :administrative_areas
end
