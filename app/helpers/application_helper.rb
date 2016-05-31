module ApplicationHelper

  def follower_links(users)
    users.collect do |u|
      content_tag :a, u.name, url: '#'
    end.to_sentence.html_safe
  end

  def emph_none
    content_tag :span, 'none', class: 'highlight'
  end

  def state_t(value)
    I18n.t('state.' + value.to_s.parameterize)
  end

  def state_progress_bar(current_state, resolution)
    states = ['draft', 'submitted', 'open', 'in_progress', 'closed']

    html_tags = states.collect do |state|
      content_tag :span, I18n.t('state.'+state), class: "#{  current_state.include?(state) ? 'current' : '' }"
    end
    html_tags.join(' > ').html_safe
  end

  def can_do?(user, terms)
     terms.include?(user.role) ||
     (terms.include?("admin") && user.is_admin?)
  end

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

  def render_markdown(text, sanitize = 'basic')
    if sanitize == "restricted"
      sanitize = {
        elements: ['br', 'a'],
        attributes: { 'a' => ['href', 'title'] },
        protocols: { 'a' => {'href' => ['http', 'https', 'mailto', :relative] }}
      }
    elsif sanitize == "basic"
      sanitize = Sanitize::Config::BASIC
    elsif sanitize == "relaxed"
      sanitize = Sanitize::Config::RELAXED if sanitize == "relaxed"
    end
    if text.present?
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, strikethrough: true)
      Sanitize.fragment(
        markdown.render( text ),
        sanitize
      ).html_safe
    end
  end

  def updated_at_human(object)
    if object && object.try(:updated_at)
      the_time = object.updated_at
    else
      the_time = object
    end

    if the_time > Time.now - 1.minute
      'just now'
    elsif the_time > Time.now - 5.minute
      'less than 5 minutes ago'
    elsif the_time > Time.now - 10.minute
      'less than 10 minutes ago'
    elsif the_time > Time.now - 15.minute
      'in the last 15 minutes'
    elsif the_time > Time.now - 30.minute
      'in the last 30 minutes'
    elsif the_time > Time.now - 1.hour
      'in the last hour'
    elsif the_time > Time.now - 4.hour
      'in the last few hours'
    elsif the_time.today?
      'today'
    elsif (the_time - 1.day).today?
      'yesterday'
    elsif the_time > Time.now - 1.year
      the_time.strftime("%a %d %b")
    else
      the_time.strftime("%a %d %b %Y")
    end
  end


  def updated_summary(object)
    if object && object.try(:updated_at)
      the_time = object.updated_at
    else
      the_time = object
    end

    if the_time > (Time.now - 1.hour)
      'recently'
    elsif the_time.today?
      'today'
    elsif (the_time+1.day).today?
      'yesterday'
    end
  end

  def can_publish_issue?(issue)
    current_user.is_admin? || current_user.role == "staff" ||
    (current_user.ranger_like? && current_user.routes.include?(issue.route) && current_user.administrative_areas.include?(issue.administrative_area))
  end

  def can_close_issue?(issue)
    current_user.is_admin? || current_user.role == "staff" ||
    (current_user.ranger_like? && current_user.routes.include?(issue.route) && current_user.administrative_areas.include?(issue.administrative_area)) ||
    current_user == @issue.user
  end

  def marker_style(priority, state = nil)

    if priority.present? && priority > 0
      marker_colour = "green-dot" if priority == 1
      marker_colour = "yellow-dot" if priority == 2
      marker_colour = "red-dot" if priority == 3
    else
      marker_colour = "blue-dot"
    end
    marker_colour = "grey" if state == "closed"

    "https://maps.google.com/mapfiles/ms/icons/"+marker_colour+".png"
  end

  def get_issue_coord_stats(issues)
    if issues.present?
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
        average_coord: [total_lat/issues.length, total_lng/issues.length],
        max_lat: max_lat, min_lat: min_lat, max_lng: max_lng, min_lng: min_lng,
        max_spread: max_spread
      }
    end
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
        category - #{ issue.the_problem } <span style='float:right'>#{ issue.state.humanize.upcase }</span> </h3>
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
      tab_link(tab_name, order, current_order, direction, filter_params(params)),
      class: 'tab ' + (params[:order] == order ? 'selected' : ''),
      title: 'Sort by ' + tab_title
    )
  end

  def filter_params(params, new_params = {})
    the_params = params.permit(Rails.application.config.filter_params)
    the_params.merge!(new_params).symbolize_keys
  end

  def issue_number_path2(issue, params = {}, new_params = {})
    new_params[:issue_number] = issue.issue_number
    issue_number_path( filter_params( params, new_params ) )
  end

  def generate_issue_title(issue)
    title = (issue.category.present? ? issue.category.name : '') +
            (issue.problem.present? ? (' - ' + issue.problem.name) : '') + " - #{ issue.state.parameterize.gsub('_', ' ') }"
    title = issue.title unless title.present?
    '(' + issue.issue_number.to_s + ') ' + title
  end

end
