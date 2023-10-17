# Cloudinary Service contains methods to upload files to Cloudinary.
#
# It will be ready to be used only if all the environment variables are set.
#
# Environment variables:
#
# - CLOUDINARY_API_KEY
# - CLOUDINARY_API_SECRET
# - CLOUDINARY_PROJECT_NAME
#
# You can find the values for these variables in the Cloudinary dashboard:
# https://cloudinary.com/console. For more details on how to get these values,
# check the README of this project.
#
# Tech documentation about the implementation:
# * https://cloudinary.com/documentation/ruby_rails_quickstart
class CloudinaryService < CloudService
  # Upload a file to Cloudinary. It will return a hash with the following
  # information:
  #
  # - project: The name of the project
  # - folder: The folder where the file was uploaded
  # - url: The url of the file
  # - service: The name of the service
  # - response: The response from the service
  #
  # If the service is not configured, it will return nil.
  #
  # @param url [String] The url of the file to upload
  # @param file_name [String] The name of the file. If not set, it will extract
  #   the name of the file from the url.
  # @param options [Hash] Additional options
  #
  # Available options are:
  #
  # - remote_folder: The folder, on Cloudinary, where the file will be uploaded
  #   to. If not set, it will use an empty string, which means the file will
  #   be uploaded to the root folder.
  #
  # @return [Hash, nil] The response from the service or nil if the service is
  #   not configured.
  #
  # @example Upload a file to Cloudinary
  #   cloudinary_service = CloudinaryService.new(project)
  #   cloudinary_service.upload(url: "https://example.com/image.jpg")
  #
  # @example Upload a file to a folder on Cloudinary
  #   cloudinary_service = CloudinaryService.new(project)
  #   cloudinary_service.upload(
  #     url: "https://example.com/image.jpg",
  #     options: { remote_folder: "images" }
  #   )
  def upload(url:, file_name: nil, options: {})
    return unless configured?

    file_name ||= File.basename(url)
    remote_folder = options[:remote_folder].to_s

    response = Cloudinary::Uploader.upload(
      url,
      folder: remote_folder,
      public_id: file_name,
      display_name: file_name
    )

    parse_response(url: response["url"], folder: response["folder"], response: response)
  end

  private

  def configured?
    @errors = []
    api_key = get_env("CLOUDINARY_API_KEY")
    api_secret = get_env("CLOUDINARY_API_SECRET")
    project_name = get_env("CLOUDINARY_PROJECT_NAME")

    return false unless errors.empty?

    configure_cloudinary(api_key, api_secret, project_name)
  end

  def configure_cloudinary(api_key, api_secret, project_name)
    url = "cloudinary://#{api_key}:#{api_secret}@#{project_name}"
    Cloudinary.config_from_url(url)
    Cloudinary.config do |config|
      config.secure = true
    end

    true
  end
end
