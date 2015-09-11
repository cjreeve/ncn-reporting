class SiteController < ApplicationController
  def notifications
    user_routes = current_user.routes.to_a
    @user_route_slugs = user_routes.collect(&:slug).join('.')

    user_areas = current_user.areas.to_a
    @user_area_ids = user_areas.collect(&:id).join('.')

    has_routes = user_routes.present? && user_areas.present?


    @user_draft_issue_count = Issue.where(user: current_user, state: 'draft').count

    @user_submitted_issue_count = 0
    if %w{ranger admin}.include?(current_user.role) && has_routes
      @user_submitted_issue_count = Issue.where(state: 'submitted', route: user_routes, area: user_areas).count
    end

    @user_resolved_issue_count = 0
    if %w{ranger admin}.include?(current_user.role) && has_routes
      @user_resolved_issue_count = Issue.where(state: 'resolved', route: user_routes, area: user_areas).count
    end

    @own_issue_resolved_count = Issue.where(state: 'resolved', user: current_user).count
    @own_issue_unsolvable_count = Issue.where(state: 'unsolveable', user: current_user).count

    @number_of_possitive_counters = [
      @user_draft_issue_count > 0,
      @user_submitted_issue_count > 0,
      @user_resolved_issue_count > 0,
      @own_issue_resolved_count > 0,
      @own_issue_unsolvable_count > 0
    ].count(true)

    @total_pending_count =  @user_draft_issue_count +
                            @user_submitted_issue_count +
                            @user_resolved_issue_count +
                            @own_issue_resolved_count +
                            @own_issue_unsolvable_count

    render layout: false
  end
end
