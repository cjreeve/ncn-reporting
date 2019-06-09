class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  respond_to :html

  def index
    per_page = Rails.application.config.comments_per_page
    @issue = Issue.find_by_id(params[:issue_id])
    @comments = @issue.comments.order(created_at: :desc).paginate(page: params[:page], per_page: per_page)
    @last_comment = @comments.first
    respond_to do |format|
      format.js { return (render :index) }
    end
  end

  def new
    @comment = Comment.new
    respond_with(@comment)
  end

  def edit
    @last_comment = @comment
  end

  def create
    @comment = Comment.new(comment_params)
    @new_comment = Comment.new
    @comments = Comment.where(issue: @comment.issue).order(created_at: :asc)
    @issue = @comment.issue
    followers = @issue.followers - [current_user]

    respond_to do |format|
      if @comment.save
        if image = @comment.image
          image.owner_id = @comment.issue_id
          image.owner_type = "Issue"
          image.caption = @comment.content[0..200]
          image.save
        end
        @issue.followers << current_user
        @issue.save
        @last_comment = @comment

        format.html { redirect_to :show, status: :created }
        format.js {
          return (render :comment)
        }
        followers.each do |follower|
          UserNotifier.send_issue_comment_notification(follower, @comment, @issue, current_user).deliver
        end
      else
        @validation_errors = true
        format.js { return render :comment }
      end
    end
  end


  def update
    @comment.update(comment_params)
    @last_comment = @comment
  end

  def destroy
    @new_comment = Comment.new
    @comments = Comment.where(issue: @comment.issue)
    @issue = @comment.issue
    respond_to do |format|
      if @comment.destroy
        format.html { redirect_to :show, status: :created }
        format.js {
          return (render :destroy)
        }
      else
        format.html { return render :show }
        # format.js { return an error message }
      end
    end
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:content, :user_id, :issue_id, image_attributes: [:id, :src])
    end
end
