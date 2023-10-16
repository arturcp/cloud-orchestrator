class ApplicationController < ActionController::API
  before_action :authenticate_request

  attr_reader :current_project

  private

  def authenticate_request
    current_token = request.headers["X-Api-Key"]

    @current_project = Projects.get_by_token(current_token)

    render json: { error: "Not Authorized" }, status: :unauthorized unless current_project
  end
end
