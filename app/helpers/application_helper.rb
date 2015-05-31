module ApplicationHelper

  def marker_style(priority, state = nil)
    if priority.present?
      marker_colour = "green" if priority == 1
      marker_colour = "yellow" if priority == 2
      marker_colour = "red" if priority == 3
    else
      marker_colour = "blue"
    end
    "http://maps.google.com/mapfiles/ms/icons/"+marker_colour+"-dot.png"
  end
end
