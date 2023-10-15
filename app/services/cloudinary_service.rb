class CloudinaryService < CloudService
  def upload(url:, file_name: nil, options: {})
    return unless configured?

    file_name ||= File.basename(url)
    remote_folder = options[:remote_folder].to_s

    response = Cloudinary::Uploader.upload(url,
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

    url = "cloudinary://#{api_key}:#{api_secret}@#{project_name}"
    Cloudinary.config_from_url(url)
    Cloudinary.config do |config|
      config.secure = true
    end

    true
  end
end
