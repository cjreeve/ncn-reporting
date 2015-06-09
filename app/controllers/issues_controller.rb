class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy]

  # GET /issues
  # GET /issues.json
  def index
    @issues = Issue.all.order('issue_number DESC')
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    @issues = Issue.all.order('lng DESC')
  end

  # GET /issues/new
  def new
    @issue = Issue.new
  end

  # GET /issues/1/edit
  def edit
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)

    respond_to do |format|
      if @issue.save
        format.html { redirect_to @issue, notice: 'Issue was successfully created.' }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { render :new }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    respond_to do |format|
      if @issue.update(issue_params)
        format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @issue }
      else
        format.html { render :edit }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @issue.destroy
    respond_to do |format|
      format.html { redirect_to issues_url, notice: 'Issue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def publish
    @issue = Issue.find(params[:id])
    @issue.publish!
    @issues = Issue.all.order('lng DESC')
    render :show
  end

  def archive
    @issue = Issue.find(params[:id])
    @issue.archive!
    @issues = Issue.all.order('lng DESC')
    render :show
  end

  def resolve
    @issue = Issue.find(params[:id])
    @issue.resolve!
    @issues = Issue.all.order('lng DESC')
    render :show
  end

  def reject
    @issue = Issue.find(params[:id])
    @issue.reject!
    @issues = Issue.all.order('lng DESC')
    redirect :show
  end

  def reopen
    @issue = Issue.find(params[:id])
    @issue.reopen!
    @issues = Issue.all.order('lng DESC')
    render :show
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
      @issue.coordinate = "#{@issue.lat}, #{@issue.lng}"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:issue_number, :title, :description, :priority, :time_reported,
        :time_completed, :location_name, :coordinate)
    end
end
