class Region < ActiveRecord::Base

  has_many :users

  validates :name, length: { in: 2..40 }, uniqueness: true

end
