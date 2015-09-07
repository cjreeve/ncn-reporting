class SiteController < ApplicationController
  def notifications
    @user_draft_issue_count = Issue.where(user: current_user, state: 'draft').count
    render layout: false
  end
end
