class UserNotifier < ActionMailer::Base

  default from: "ncn-reporting <noreply@ncn-reporting.herokuapp.com>"

  def send_user_notifications(user)
    @user = user

    return if @user.is_locked? || @user.role == "guest" || %w{volunteer ranger administrator"}.include?(@user.name)

    #################### shared with ajax notifier ###################
    counter_array = []
    user_routes = @user.routes.to_a
    @user_route_slugs = user_routes.collect(&:slug).join('.')

    user_areas = @user.areas.to_a
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

    if @own_draft_issue_count > 0
      @old_issue = (Issue.where(user: User.first, state: 'draft').order(updated_at: :asc).first.updated_at < (DateTime.now - 2.weeks))
    end

    return if @total_pending_count == 0

    if Rails.env.production?
      recipient_email = @user.email
    else
      recipient_email = Rails.application.config.dev_email
    end

    mail( to: recipient_email,
          subject: "ncn-reporting - #{ @total_pending_count.to_s + ' issue'.pluralize } for your attention" )
  end
end
