class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    valid_token = ENV["CLOUD_ORCHESTRATOR_TOKEN"]
    current_token = request.headers["X-Api-Key"]
    render json: { error: 'Not Authorized' }, status: 401 unless valid_token == current_token
  end
end
