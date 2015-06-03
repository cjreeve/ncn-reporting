module ApplicationHelper

  def marker_style(priority, state = nil)
    if priority.present? && priority > 0
      marker_colour = "green" if priority == 1
      marker_colour = "yellow" if priority == 2
      marker_colour = "red" if priority == 3
    else
      marker_colour = "blue"
    end
    "http://maps.google.com/mapfiles/ms/icons/"+marker_colour+"-dot.png"
  end

  def get_issue_coord_stats(issues)
    total_lat = 0.0
    total_lng = 0.0
    max_lat = issues.first.lat
    min_lat = issues.first.lat
    max_lng = issues.first.lng
    min_lng = issues.first.lng
    issues.each do |issue|
      total_lat += issue.lat
      total_lng += issue.lng
      max_lat = issue.lat if issue.lat > max_lat
      min_lat = issue.lat if issue.lat < min_lat
      max_lng = issue.lng if issue.lng > max_lng
      min_lng = issue.lng if issue.lng < min_lng
    end
    max_spread = (max_lat - min_lat > max_lng - min_lng) ? (max_lat - min_lat) : (max_lng - min_lng)
    max_spread = 0.06 if max_spread == 0
    {
      average_coord: [total_lat/issues.count, total_lng/issues.count],
      max_lat: max_lat, min_lat: min_lat, max_lng: max_lng, min_lng: min_lng,
      max_spread: max_spread
    }
  end

  def priority_colour(priority)
    case priority
    when 3
      '#F99'
    when 2
      '#FE9'
    when 1
      '#A8F5A8'
    else
      '#EEF'
    end
  end

  def formatted_description(title, text)
    '<div id="content">' +
      '<div id="siteNotice">'+'</div>'+
      '<h3 id="firstHeading" class="firstHeading">' + title + '</h3>'+
      '<div id="bodyContent">'+
        '<p>' + text + '</p>' +
      '</div>' +
    '</div>'
  end

end
