class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ROLES = %w[staff coordinator ranger volunteer guest]

  has_many :issues
  has_many :comments
  has_many :user_managed_route_selections
  has_many :routes, through: :user_managed_route_selections
  has_many :user_managed_area_selections
  has_many :areas, through: :user_managed_area_selections
  has_many :user_label_selections
  has_many :labels, through: :user_label_selections

  def removable?
    self.issues.limit(1).blank? && self.comments.limit(1).blank?
  end

end
