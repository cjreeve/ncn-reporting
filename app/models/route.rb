class Route < ApplicationRecord

  has_many :issues
  has_many :user_managed_route_selections
  has_many :users, through: :user_managed_route_selections
  has_many :segments, dependent: :destroy

  before_validation :set_slug


  def set_slug
    self.slug = self.name.parameterize
  end

end
