class UserAdminAreaSelection < ActiveRecord::Base
  belongs_to :user
  belongs_to :administrative_area
end
