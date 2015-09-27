class UpdatesController < ApplicationController
  def show

    # @updates = []

    @issues = Issue.where('updated_at > ?', Time.zone.now - 10.days).order('updated_at DESC').includes(:comments)
    # @issues.each do |issue|
    #   if issue.edited_at == issue.updated_at
    #     @updates << { issue_id: issue.id, action: :edited }
    #   elsif issue.updated_at == published_at
    #     # user published issue

    #   elsif issue.comments.present? && (issue.updated_at - issue.comments.last.updated_at).abs < 1
    #     @updates << { issue_id: issue.id, action: :commented }
    #   end
    # end
  end
end
