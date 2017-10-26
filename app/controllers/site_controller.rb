class SiteController < ApplicationController
  # load_and_authorize_resource

  def welcome
  end

  def notifications
    return nil unless current_user
    @user = current_user

    #################### shared with email notifier ###################
    counter_array = []
    user_routes = @user.routes.to_a
    @user_route_slugs = user_routes.collect(&:slug).join('.')

    user_areas = @user.administrative_areas.to_a
    @user_area_ids = user_areas.collect(&:id).join('.')
    user_labels = @user.labels
    @label_ids = Hash[ user_labels.collect { |l| [l.name.parameterize.to_sym, l.id] } ]

    @total_pending_count = [
      @own_draft_issue_count = @user.own_draft_issue_count,
      @own_issue_resolved_count = @user.own_issue_resolved_count,
      @own_issue_unsolvable_count = @user.own_issue_unsolvable_count,
      @user_submitted_issue_count = @user.user_submitted_issue_count(user_areas, user_routes),
      @user_resolved_issue_count = @user.user_resolved_issue_count(user_areas, user_routes)
    ].sum

    @open_label_counts = @user.open_label_counts(user_labels, user_areas, user_routes)
    @total_pending_count += @open_label_counts.values.sum
    ####################################################################

    render layout: false
  end



  def notification_emails
    if current_user && current_user.is_admin?
      # disabled only sending emails to current region as there are no admins for other regions
      # region: @current_region
      User.where(is_locked: false).where.not(role: "guest").each do |user|
        UserNotifier.send_user_notifications(user).deliver
      end
      Region.first.update_attributes(notifications_sent_at: Time.zone.now)
      redirect_to admin_users_path, notice: "Notification emails sent"
    else
      redirect_to root_path
    end
  end


  def updates_count
    return nil unless current_user
    last_visit = current_user.visited_updates_at
    @updates_count = Issue.where('updated_at > ?', last_visit).count
    @updates_count += Page.where('updated_at > ?', last_visit).count
    render layout: false
  end

  def mini_search
    @search_type = params[:type]
    @category = params[:category]
    @mini_search_results = @search_type.classify.constantize.order(:name).where("name ILIKE ?", "%#{ params[:query] }%").limit(10)
  end

end
