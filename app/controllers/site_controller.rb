class SiteController < ApplicationController
  # load_and_authorize_resource

  def welcome
  end

  def notifications
    counter_array = []
    user_routes = current_user.routes.to_a
    @user_route_slugs = user_routes.collect(&:slug).join('.')

    user_areas = current_user.areas.to_a
    @user_area_ids = user_areas.collect(&:id).join('.')

    @user_draft_issue_count = Issue.where(user: current_user, state: 'draft').count
    @own_issue_resolved_count = Issue.where(state: 'resolved', user: current_user).count
    @own_issue_unsolvable_count = Issue.where(state: 'unsolvable', user: current_user).count
    counter_array << @user_draft_issue_count
    counter_array << @own_issue_resolved_count
    counter_array << @own_issue_unsolvable_count



    @user_submitted_issue_count = 0
    if %w{ranger coordinator}.include?(current_user.role) && user_areas.present?
      options = { state: 'submitted', area: user_areas }
      options[:routes] = user_routes if user_routes.present?
      @user_submitted_issue_count = Issue.where(options).count
    end
    counter_array << @user_submitted_issue_count



    @user_resolved_issue_count = 0
    if %w{ranger coordinator}.include?(current_user.role) && user_areas.present?
      options = { state: 'resolved', area: user_areas }
      options[:routes] = user_routes if user_routes.present?
      @user_resolved_issue_count = Issue.where(options).count
    end
    counter_array << @user_resolved_issue_count


    # OPEN LABEL ISSUES

    @open_label_count = {}
    @label_ids = {}

    current_user.labels.each do |label|
      options = {state: ["open", "reopened"]}
      options[:labels] = {name: label.name}
      options[:area] = user_areas if user_areas.present? && !(user_areas.one? && user_areas.first.name.downcase == "other")
      options[:route] =  user_routes if user_routes.present? && !(user_routes.one? && user_routes.first.name.downcase == "other")
      label_key = label.name.parameterize.to_sym
      @open_label_count[label_key] = Issue.joins(:labels).where(options).uniq.count
      @label_ids[label_key] = label.id
    end

    @open_label_count.values.each do |n|
      counter_array << n
    end

    @number_of_possitive_counters = counter_array.collect{ |x| x > 0 }.count(true)
    @total_pending_count = counter_array.sum
    render layout: false
  end


  def updates_count
    last_visit = current_user.visited_updates_at
    @updates_count = Issue.where('updated_at > ?', last_visit).count
    @updates_count += Page.where('updated_at > ?', last_visit).count
    render layout: false
  end

end
