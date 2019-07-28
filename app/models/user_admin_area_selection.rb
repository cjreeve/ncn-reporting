class UserAdminAreaSelection < ApplicationRecord
  belongs_to :user
  belongs_to :administrative_area
end
