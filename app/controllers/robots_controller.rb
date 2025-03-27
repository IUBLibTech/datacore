class RobotsController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :find_robots_txt
  before_action :throw_breadcrumbs, except: :show
  layout 'hyrax/dashboard'

  def show
    render body: @robots_txt.value
  end

  def edit
    authorize! :edit, @robots_txt
  end

  def update
    authorize! :update, @robots_txt
    respond_to do |format|
      if @robots_txt.update(permitted_params)
        format.html { redirect_to edit_robots_path, notice: 'robots.txt updated.' }
      else
        flash.now[:alert] = "robots.txt could not be updated. #{@robots_txt.errors.full_messages}"
        format.html { render :edit }
      end
    end
  end

  private

  def find_robots_txt
    @robots_txt = ContentBlock.find_or_create_by(name: 'robots_txt')
  end

  def throw_breadcrumbs
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb t(:'hyrax.admin.sidebar.configuration'), '#'
    add_breadcrumb 'robots.txt', edit_robots_path
  end

  def permitted_params
    params.require(:content_block).permit(:value)
  end
end