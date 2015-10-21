module ApplicationHelper

  def user_links(users)
    if users.present?
      users.collect { |u| link_to u.name.gsub('(sustrans)',''), user_path(u) }.to_sentence.html_safe
    else
      'none'
    end
  end

  def strip_markdown(text)
    strip_tags(render_markdown(text))
  end

  def render_markdown(text)
    if text.present?
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      Sanitize.fragment(
        markdown.render( strip_tags text ),
        Sanitize::Config::BASIC
      ).html_safe
    end
  end

  def updated_at_human(object)
    if object.updated_at > Time.now - 1.minute
      'just now'
    elsif object.updated_at > Time.now - 5.minute
      'less than 5 minutes ago'
    elsif object.updated_at > Time.now - 10.minute
      'less than 10 minutes ago'
    elsif object.updated_at > Time.now - 15.minute
      'in the last 15 minutes'
    elsif object.updated_at > Time.now - 30.minute
      'in the last 30 minutes'
    elsif object.updated_at > Time.now - 1.hour
      'in the last hour'
    elsif object.updated_at > Time.now - 4.hour
      'in the last few hours'
    elsif object.updated_at.today?
      'today'
    elsif (object.updated_at - 1.day).today?
      'yesterday'
    elsif object.updated_at > Time.now - 1.year
      object.updated_at.strftime("%a %d %b")
    else
      object.updated_at.strftime("%a %d %b %Y")
    end
  end


  def updated_summary(object)
    if object.updated_at > (Time.now - 1.hour)
      'recently'
    elsif object.updated_at.today?
      'today'
    elsif (object.updated_at+1.day).today?
      'yesterday'
    end
  end

  def can_publish_issue?(issue)
    current_user.role == "admin" || current_user.role == "staff" ||
    (current_user.role == "ranger" && current_user.routes.include?(issue.route) && current_user.areas.include?(issue.area))
  end

  def can_close_issue?(issue)
    current_user.role == "admin" || current_user.role == "staff" ||
    (current_user.role == "ranger" && current_user.routes.include?(issue.route) && current_user.areas.include?(issue.area)) ||
    current_user == @issue.user
  end

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

  def formatted_description(issue)
    category = (issue.category.present? ? issue.category.name : '')
    "<div id='content'
      <div id='siteNotice'>
      </div>
      <h3 id='firstHeading' class='firstHeading'>(#{ issue.issue_number.to_s } )
        category - #{ issue.the_problem } <span style='float:right'>(#{ issue.state })</span> </h3>
      <div id='bodyContent'>
        <p> #{ strip_tags(render_markdown(issue.description.gsub(/"/,"'"))) } </p>
        <p> <a href='/issue/#{ issue.issue_number.to_s }'> Go to issue ► </a> </p>
      </div>
    </div>".squish.html_safe
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
      "#{name}#{ tab_arrow(this_order, current_order, direction) }".html_safe
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
    the_params[:dir] = params[:dir] if params[:dir]
    the_params[:order] = params[:order] if params[:order]
    the_params[:route] = params[:route] if params[:route]
    the_params[:area] = params[:area] if params[:area]
    the_params[:state] = params[:state] if params[:state]
    the_params[:region] = params[:region] if params[:region]
    the_params[:user] = params[:user] if params[:user]
    the_params[:label] = params[:label] if params[:label]
    the_params.merge!(new_params)
  end

  def generate_issue_title(issue)
    title = (issue.category.present? ? issue.category.name : '') +
            (issue.problem.present? ? (' - ' + issue.problem.name) : '')
    title = issue.title unless title.present?
    '(' + issue.issue_number.to_s + ') ' + title
  end

end
