class ImagesController < ApplicationController
  before_action :set_image, only: [:destroy]
  load_and_authorize_resource
  respond_to :html, :js

  # GET /images
  # GET /images.json
  def index
    @images = Image.all
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    respond_to do |format|
      if @image.update(image_params)
        # format.html { redirect_to user_path(current_user), notice: 'Image was successfully uploaded.' }
        format.js { render :show }
      else
        # format.html { render 'registration/edit' }
        format.js { render :show }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update

    @image = Image.find(image_params[:id])

    respond_to do |format|
      if @image.update(image_params)
        # format.html { redirect_to user_path(current_user), notice: 'Image was successfully uploaded.' }
        format.js { render :show }
      else
        # format.html { render :edit }
        format.js { render :show }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.js { render :show }
    end
  end

  def rotate
    @image = Image.find(params[:id])
    @image.text_to_rotation(params[:direction])
    @image.rotate_image!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(:id, :src, :url, :caption, :owner_id, :owner_id, :owner_type)
    end
end
