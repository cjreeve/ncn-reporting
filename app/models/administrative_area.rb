class AdministrativeArea < ActiveRecord::Base
  has_many :issues
  belongs_to :area

  def short_name
    self[:short_name].blank? ? self.name : self[:short_name]
  end

end
