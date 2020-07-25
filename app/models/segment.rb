class Segment < ApplicationRecord
  belongs_to :route
  belongs_to :administrative_area
  belongs_to :region
  belongs_to :ranger, class_name: 'User', foreign_key: :last_checked_by_id

  serialize :track
  attr_accessor :track_points
  attr_accessor :track_file

  validates_presence_of :administrative_area, :route, :region
  # validate :track_points_format

  before_validation :set_coordinate
  before_validation :set_name
  before_validation do
    self.location&.strip!
  end

  def track_points=(new_track_points)
    doc = Nokogiri::XML("<trkseg>"+new_track_points+"</trkseg>")
    self.track = doc.xpath('//trkpt').collect do |track_point|
      [track_point.xpath('@lat').to_s.to_f.round(5), track_point.xpath('@lon').to_s.to_f.round(5)]
    end
  end

  def track_points
    return unless track
    track.collect do |track_point|
      <<~STRING
        <trkpt lat="#{track_point.first}" lon="#{track_point.last}" />
      STRING
    end.join
  end

  def google_track
    track.collect{ |x| {lat: x[0], lng: x[1]} }
  end

  def description
    if formatted_last_checked_date
      "<b>#{name}</b><br>last checked by #{ranger_name}<br>on #{formatted_last_checked_date}"
    else
      "#{name} has no record of being checked"
    end
  end

  def formatted_last_checked_date
    return unless last_checked_on
    @formatted_last_checked_date ||= last_checked_on.strftime("%A %d %B %Y")
  end

  def alert_level
    return 3 if !last_checked_on || last_checked_on < 6.months.ago
    return 2 if last_checked_on < 1.month.ago
    1
  end

  def check!(ranger)
    update_attributes last_checked_by_id: ranger.id, last_checked_on: Date.today
  end

  def ranger_name
    ranger&.name || "unknown"
  end

  private

  def track_points_format

  end

  def set_name
    return unless administrative_area && route
    if administrative_area_id_changed? || route_id_changed? || location_changed?
      location_string = location.present? ? " (#{location})" : ""
      self.name = "#{route.name} #{administrative_area.short_name}#{location_string}"
    end
  end

  def set_coordinate
    return unless track.present?
    if track_changed? || !lat
      middle_coordinate = find_middle
      self.lat = middle_coordinate[:lat]
      self.lng = middle_coordinate[:lng]
    end
  end

  def find_middle
    track_points_count = track.count
    middle_index = (track_points_count*0.5+0.5).to_i
    lat = track[middle_index].first
    lng = track[middle_index].last

    {lat: lat, lng: lng}
  end
end
