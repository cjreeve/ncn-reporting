class UpdatesController < ApplicationController
    load_and_authorize_resource

  def show

    @issues = Issue.where('updated_at > ?', Time.zone.now - 10.days).order('updated_at DESC').includes(:comments)

  end
end
