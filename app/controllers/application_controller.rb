class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  around_action :error_handling


  def error_handling
    yield 
  rescue Request::HttpBaseError => e
    render json: { message: e.message }, status: e.status
  rescue => e
    notify_error(e)
    render json: { message: "Internal service error" }, status: 500
  end

  def notify_error(e)
    if Rails.env.development? || Rails.env.test?
      puts "Erro: #{e.message}"
    end
  end
end
