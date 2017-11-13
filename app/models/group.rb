class Group < ActiveRecord::Base

  has_many :issues

  has_many :user_managed_group_selections
  has_many :users, through: :user_managed_group_selections

  has_many :administrative_areas

  belongs_to :region

  validates :name, uniqueness: true

end
