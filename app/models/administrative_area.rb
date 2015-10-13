class AdministrativeArea < ActiveRecord::Base
  has_many :issues
  belongs_to :area

  before_validation :set_blank_short_name

  def set_blank_short_name
    self.short_name = self.name unless self[:short_name].present?
  end

  def short_name
    self[:short_name].blank? ? self.name : self[:short_name]
  end



end
