class SiteController < ApplicationController
  def notifications
    @user_draft_issue_count = Issue.where(user: current_user, state: 'draft').count

    @user_submitted_issue_count = 0
    if %w{ranger}.include?(current_user.role)
      user_routes = current_user.routes.to_a
      user_areas = current_user.areas.to_a
      if user_routes.present? && user_areas.present?
        @user_submitted_issue_count = Issue.where(state: 'submitted', route: user_routes, area: user_areas).count
      end
    end

    @number_of_possitive_counters = [@user_draft_issue_count > 0, @user_submitted_issue_count > 0].count(true)

    @total_pending_count = @user_draft_issue_count + @user_submitted_issue_count

    render layout: false
  end
end
