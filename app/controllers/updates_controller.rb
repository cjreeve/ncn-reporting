class UpdatesController < ApplicationController
    load_and_authorize_resource

  def show
    time_ago = Time.zone.now - 10.days

    @issues = Issue.where('updated_at > ?', time_ago).order('updated_at DESC').includes(:comments)
    @page_ids_and_update_times = Page.where('updated_at > ?', time_ago).order('updated_at ASC').pluck(:slug, :updated_at, :name)

    current_user.visited_updates_at = Time.now
    current_user.save
  end
end
