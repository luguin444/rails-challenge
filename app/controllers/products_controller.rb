class HealthController < ApplicationController
  def index
    render json: { status: 'OK2' }
  end
end