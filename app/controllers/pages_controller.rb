class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @pages = Page.all
    respond_with(@pages)
  end

  def show
    respond_with(@page)
  end

  def new
    @page = Page.new
    respond_with(@page)
  end

  def edit
  end

  def create
    @page = Page.new(page_params)
    @page.save
    respond_with(@page.slug)
  end

  def update
    @page.update(page_params)
    respond_with(@page)
  end

  def destroy
    @page.destroy
    respond_with(@page)
  end

  def view
    @page = Page.find_by(slug: params[:slug])
  end

  def controls
  end

  def welcome
  end

  def main
    @page = Page.find_or_create_by(slug: 'welcome')
    if @page.content.blank? || @page.name.blank?
      @page.name ||= 'Welcome'
      @page.content ||= '# Welcome'
      @page.save
    end
  end

  private
    def set_page
      @page = Page.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:name, :slug, :content, :role)
    end
end
