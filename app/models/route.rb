class Route < ActiveRecord::Base

  has_many :issues

  before_validation :set_slug


  def set_slug
    self.slug = self.name.parameterize
  end
  
end
