class UserManagedAreaSelection < ActiveRecord::Base
  belongs_to :user
  belongs_to :area
end
