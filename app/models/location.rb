class Location < ActiveRecord::Base
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

  before_validation do
    # avoid returning old result if gecoder fails
    # should really keep a list of recent searches to avoid using up search quota
    self.latitude = self.longitude = 0 if self.address_changed?
  end
end
