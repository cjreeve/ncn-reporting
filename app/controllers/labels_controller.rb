class LabelsController < ApplicationController
  before_action :set_label, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  respond_to :html

  def index
    @labels = Label.all
    respond_with(@labels)
  end

  def show
    respond_with(@label)
  end

  def new
    @label = Label.new
    respond_with(@label)
  end

  def edit
  end

  def create
    @label = Label.new(label_params)
    @label.save
    respond_with(@label)
  end

  def update
    @label.update(label_params)
    respond_with(@label)
  end

  def destroy
    @label.destroy
    respond_with(@label)
  end

  private
    def set_label
      @label = Label.find(params[:id])
    end

    def label_params
      params.require(:label).permit(:name)
    end
end
