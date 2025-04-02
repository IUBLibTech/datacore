class RackAttacksController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :load_rack_attack_config
  before_action :throw_breadcrumbs, except: :show
  layout 'hyrax/dashboard'

  def show
    render body: @rack_attack_config.value
  end

  def edit
    authorize! :edit, @rack_attack_config
  end

  def update
    authorize! :update, @rack_attack_config
    respond_to do |format|
      if Datacore::RackAttackConfig.save_config(permitted_params[:value])
        format.html { redirect_to edit_rack_attack_path, notice: 'Rack Attack config updated.' }
      else
        flash.now[:alert] = "Rack Attack config could not be saved. Check syntax?"
        @rack_attack_config.value = permitted_params[:value]
        format.html { render :edit }
      end
    end
  end

  private

  def load_rack_attack_config
    @rack_attack_config = Datacore::RackAttackConfig.config_source
  end

  def throw_breadcrumbs
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb t(:'hyrax.admin.sidebar.configuration'), '#'
    add_breadcrumb 'Rack Attack', edit_rack_attack_path
  end

  def permitted_params
    params.require(:content_block).permit(:value)
  end
end
