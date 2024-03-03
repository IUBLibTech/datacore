# frozen_string_literal: true

class SdaController < ApplicationController
  protect_from_forgery with: :null_session

  def show
    if user_signed_in? && current_ability.admin?
      render plain: sda_url_for(params[:collection], "#{params[:object]}.#{params[:format]}"), status: 200
    else
      render plain: 'action unavailable', status: 403
    end
  end

  private
    def sda_url_for(collection, object, version: 1)
      Settings.sda_api.show % [collection, object, version]
    end
end
