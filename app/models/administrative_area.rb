class AdministrativeArea < ActiveRecord::Base
  has_many :issues
  belongs_to :area

  has_many :user_admin_area_selections
  has_many :users, through: :user_admin_area_selections

  before_validation :set_blank_short_name

  def set_blank_short_name
    self.short_name = self.name unless self[:short_name].present?
  end

  def short_name
    self[:short_name].blank? ? self.name : self[:short_name]
  end



end
