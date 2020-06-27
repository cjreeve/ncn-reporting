class Segment < ApplicationRecord
  belongs_to :route
  belongs_to :administrative_area

  serialize :track
end
