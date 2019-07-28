class Page < ApplicationRecord

  before_validation :set_slug
  # before_validation :set_role

  validates :name, presence: true
  validates :slug, presence: true


  protected

  def set_role
    self.role = current_user.role unless self.role.present?
  end

  def set_slug
    self.slug = self.name.parameterize unless self.slug.present?
  end

end
