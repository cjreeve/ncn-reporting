class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  respond_to :html

  def index
    @comments = Comment.all
    respond_with(@comments)
  end

  def show
    respond_with(@comment)
  end

  def new
    @comment = Comment.new
    respond_with(@comment)
  end

  def edit
  end

  def create
    @comment = Comment.new(comment_params)
    @new_comment = Comment.new
    @comments = Comment.where(issue: @comment.issue).order(created_at: :asc)
    @issue = @comment.issue

    respond_to do |format|
      if @comment.save
        @issue.touch
        format.html { redirect_to :show, status: :created }
        format.js { 
          return (render :comment) 
        }
      else
        format.html { return render :show }
        # format.js { return an error message }
      end
    end
  end

  def update
    @comment.update(comment_params)
    @comment.issue.update
    respond_with(@comment)
  end

  def destroy
    @new_comment = Comment.new
    @comments = Comment.where(issue: @comment.issue)
    @issue = @comment.issue
    respond_to do |format|
      if @comment.destroy
        format.html { redirect_to :show, status: :created }
        format.js { 
          return (render :comment) 
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
      params.require(:comment).permit(:content, :user_id, :issue_id)
    end
end
