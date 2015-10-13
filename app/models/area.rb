class Area < ActiveRecord::Base
  
  has_many :issues

  has_many :user_managed_area_selections
  has_many :users, through: :user_managed_area_selections

  has_many :administrative_areas

  before_validation :set_blank_short_name

  def set_blank_short_name
    self.short_name = self.name unless self.short_name.present?
  end
end
