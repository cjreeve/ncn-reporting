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
    max_lat = (issues.present? ? issues.first.lat : 0)
    min_lat = (issues.present? ? issues.first.lat : 0)
    max_lng = (issues.present? ? issues.first.lng : 0)
    min_lng = (issues.present? ? issues.first.lng : 0)
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
      average_coord: [total_lat/issues.length, total_lng/issues.length],
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
    title ||= ''
    text ||= ''
    '<div id="content">' +
      '<div id="siteNotice">'+'</div>'+
      '<h3 id="firstHeading" class="firstHeading">' + title + '</h3>'+
      '<div id="bodyContent">'+
        '<p>' + text + '</p>' +
      '</div>' +
    '</div>'
  end

  def tab_selection_style(params)
    if params[:order] == 'number'
      if params[:dir] == 'desc'
        'desc'
      elsif params[:dir] == 'asc'
        'asc'
      end
    end
  end

  def tab_sort_dir(this_order, current_order, direction)
    (this_order == current_order && direction == 'desc') ? :asc : :desc
  end

  def tab_arrow(this_order, current_order, direction)
    if this_order == current_order
      if direction == 'desc'
        "&darr;"
      else
        "&uarr;"
      end
    else
      "&nbsp"
    end
  end

  def tab_link(name, this_order, current_order, direction, the_params)
    the_params[:order] = this_order.to_sym
    the_params[:dir] = tab_sort_dir(this_order, current_order, direction)
    link_to issues_path(the_params) do
      "#{name} #{ tab_arrow(this_order, current_order, direction) }".html_safe
    end
  end

  def table_header(tab_name, tab_title, order, params)
    current_order = params[:order]
    direction = params[:dir]
    content_tag(
      :th,
      tab_link(tab_name, order, current_order, direction, the_params(params)),
      class: 'tab ' + (params[:order] == order ? 'selected' : ''),
      title: 'Sort by ' + tab_title
    )
  end

  def the_params(params, new_params = {})
    the_params = {}
    the_params[:dir] = params[:dir] if params[:dir].present?
    the_params[:order] = params[:order] if params[:order].present?
    the_params[:route] = params[:route] if params[:route].present?
    the_params[:area] = params[:area] if params[:area].present?
    the_params[:state] = params[:state] if params[:state].present?
    the_params.merge!(new_params)
  end

  def generate_issue_title(issue)
    title = (issue.category.present? ? issue.category.name : '') +
            (issue.problem.present? ? (' - ' + issue.problem.name) : '')
    title = issue.title unless title.present?
    title
  end

end
