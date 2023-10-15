class FilesController < ApplicationController
  def upload
    service = ServiceFactory.build(params[:service], current_project)
    response = service.upload(
      url: safe_params[:url],
      file_name: safe_params[:file_name],
      options: safe_params
    )

    if service.errors.present?
      render json: service.errors, :status => :unprocessable_entity
    else
      render json: response
    end
  end

  private

  def safe_params
    params.permit(:url, :file_name, :service, :remote_folder)
  end
end
