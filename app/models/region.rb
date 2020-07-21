class Region < ApplicationRecord

  has_many :groups
  has_many :users
  has_many :segments

  validates :name, length: { in: 2..40 }, uniqueness: true

end
