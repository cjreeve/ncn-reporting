class SiteController < ApplicationController
  def notifications
    @user_draft_issue_count = Issue.where(user: current_user, state: 'draft').count

    @user_submitted_issue_count = 0 #Issue.where(state: 'submitted', route: current_user.routes, area: current_user.areas).count

    @number_of_possitive_counters = [@user_draft_issue_count > 0, @user_submitted_issue_count > 0].count(true)

    @total_pending_count = @user_draft_issue_count + @user_submitted_issue_count

    render layout: false
  end
end
