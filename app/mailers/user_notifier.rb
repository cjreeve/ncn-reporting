class UserNotifier < ActionMailer::Base

  default from: "ncn-reporting <noreply@ncn-reporting.herokuapp.com>"

  def send_user_notifications(user)
    @user = user

    return if exclude_user? user

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
      @old_issue = (Issue.where(user: @user, state: 'draft').order(updated_at: :asc).first.updated_at < (DateTime.now - 2.weeks))
    end

    return if @total_pending_count == 0

    mail(
      to: get_recipient_email(user),
      subject: "ncn-reporting - #{ @total_pending_count.to_s + ' issue'.pluralize } for your attention"
      )
  end

  def send_issue_state_change_notification(user, issue)
    @user = user
    @issue = issue

    return if exclude_user? user

    mail(
      to: get_recipient_email(user),
      subject: "ncn-reporting - issue #{ issue.issue_number } was #{ I18n.t('action.'+issue.state) }"
    )
  end


  private

  def exclude_user?(user)
    @user.is_locked? || @user.role == "guest" || %w{volunteer ranger administrator"}.include?(@user.name) ||
           !@user.receive_email_notifications?
  end

  def get_recipient_email(user)
    if Rails.env.production?
      @user.email
    else
      Rails.application.config.dev_email
    end
  end

end
