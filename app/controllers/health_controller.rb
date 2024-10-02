class HealthController < ApplicationController
  def index
    render json: { message: 'OK' }, status: :ok
  end
end