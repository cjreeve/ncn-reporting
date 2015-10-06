class SiteController < ApplicationController
  def notifications
    counter_array = []
    user_routes = current_user.routes.to_a
    @user_route_slugs = user_routes.collect(&:slug).join('.')

    user_areas = current_user.areas.to_a
    @user_area_ids = user_areas.collect(&:id).join('.')

    has_routes = user_routes.present? && user_areas.present?


    @user_draft_issue_count = Issue.where(user: current_user, state: 'draft').count
    @own_issue_resolved_count = Issue.where(state: 'resolved', user: current_user).count
    @own_issue_unsolvable_count = Issue.where(state: 'unsolvable', user: current_user).count
    counter_array << @user_draft_issue_count
    counter_array << @own_issue_resolved_count
    counter_array << @own_issue_unsolvable_count



    @user_submitted_issue_count = 0
    if %w{ranger admin}.include?(current_user.role) && has_routes
      @user_submitted_issue_count = Issue.where(state: 'submitted', route: user_routes, area: user_areas).count
    end
    counter_array << @user_submitted_issue_count



    @user_resolved_issue_count = 0
    if %w{ranger admin}.include?(current_user.role) && has_routes
      @user_resolved_issue_count = Issue.where(state: 'resolved', route: user_routes, area: user_areas).count
    end
    counter_array << @user_resolved_issue_count


    @open_for_sustrans_count = 0
    @open_for_council_count = 0
    if %w{ staff admin }.include? current_user.role
      if user_routes.present? && user_areas.present?
        @open_for_sustrans_count = Issue.joins(:labels).where(labels: {name: 'sustrans'}, state: ["open", "reopened"], route: user_routes, area: user_areas).uniq.count
        @open_for_council_count = Issue.joins(:labels).where(labels: {name: 'council'}, state: ["open", "reopened"], route: user_routes, area: user_areas).uniq.count
      elsif user_areas.present?
        @open_for_sustrans_count = Issue.joins(:labels).where(labels: {name: 'sustrans'}, state: ["open", "reopened"], area: user_areas).uniq.count
        @open_for_council_count = Issue.joins(:labels).where(labels: {name: 'council'}, state: ["open", "reopened"], area: user_areas).uniq.count
      elsif user_routes.present?
        @open_for_sustrans_count = Issue.joins(:labels).where(labels: {name: 'sustrans'}, state: ["open", "reopened"], route: user_routes).uniq.count
        @open_for_council_count = Issue.joins(:labels).where(labels: {name: 'council'}, state: ["open", "reopened"], route: user_routes).uniq.count
      else
        @open_for_sustrans_count = Issue.joins(:labels).where(labels: {name: 'sustrans'}, state: ["open", "reopened"]).uniq.count
        @open_for_council_count = Issue.joins(:labels).where(labels: {name: 'council'}, state: ["open", "reopened"]).uniq.count
      end
      @sustrans_label_id = Label.find_or_create_by(name: 'sustrans').id
      @council_label_id = Label.find_or_create_by(name: 'council').id
    end
    counter_array << @open_for_sustrans_count
    counter_array << @open_for_council_count



    @number_of_possitive_counters = counter_array.collect{ |x| x > 0 }.count(true)
    @total_pending_count =  counter_array.sum
    render layout: false
  end
end
