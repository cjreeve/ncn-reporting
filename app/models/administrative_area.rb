class AdministrativeArea < ActiveRecord::Base
  has_many :issues

  def short_name
    self[:short_name].blank? ? self.name : self[:short_name]
  end

end
