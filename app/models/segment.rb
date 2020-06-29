class Segment < ApplicationRecord
  belongs_to :route
  belongs_to :administrative_area
  belongs_to :ranger, class_name: 'User', foreign_key: :last_checked_by_id

  serialize :track

  before_validation :set_coordinate

  def google_track
    track.collect{ |x| {lat: x[0], lng: x[1]} }
  end

  def description
    if formatted_last_checked_date
      "<b>#{name}</b><br>last checked by #{ranger.name}<br>on #{formatted_last_checked_date}"
    else
      "#{name} has no record of being checked"
    end
  end

  def formatted_last_checked_date
    return unless last_checked_at
    @formatted_last_checked_date ||= last_checked_at.strftime("%A %d %B %Y")
  end

  def alert_level
    return 3 if !last_checked_at || last_checked_at < 6.months.ago
    return 2 if last_checked_at < 1.month.ago
    1
  end

  private

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
    # lat = (track.collect(&:first).sum / track_points_count).round(5)
    # lng = (track.collect(&:last).sum / track_points_count).round(5)
    {lat: lat, lng: lng}
  end
end
