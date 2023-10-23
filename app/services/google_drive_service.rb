require "fileutils"

# GoogleDriveService contains methods to upload files to Google Drive.
#
# It will be ready to be used only if all the environment variables are set.
#
# Environment variables:
#
# - GOOGLE_SERVICE_ACCOUNT_PROJECT_ID
# - GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY_ID
# - GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY
# - GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL
# - GOOGLE_SERVICE_ACCOUNT_CLIENT_ID
# - GOOGLE_SERVICE_ACCOUNT_CERT_URL
# - GOOGLE_SERVICE_REMOTE_FOLDER_ID
#
# You can find the values for these variables in the Google Cloud dashboard:
# https://console.cloud.google.com/. For more details on how to get these values,
# check the README of this project.
class GoogleDriveService < CloudService
  API_SCOPE = "https://www.googleapis.com/auth/drive".freeze

  attr_reader :credentials_file, :credentials_file_path

  # Google Drive overrides the `self.configure` method from the CloudService
  # to create a credentials file. This file is used by the service to
  # authenticate with Google Drive. It will be located at `config/credentials`,
  # which is already on the .gitignore file, to prevent your credentials from
  # accidentally going to your code base.
  #
  # The configuration rake is run with:
  #
  # `bin/rake cloud_orchestrator:configure_services`
  #
  # rubocop:disable Metrics/AbcSize
  def self.configure(project)
    credentials = {
      type: "service_account",
      project_id: project.env["GOOGLE_SERVICE_ACCOUNT_PROJECT_ID"],
      private_key_id: project.env["GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY_ID"],
      private_key: project.env["GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY"],
      client_email: project.env["GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL"],
      client_id: project.env["GOOGLE_SERVICE_ACCOUNT_CLIENT_ID"],
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: project.env["GOOGLE_SERVICE_ACCOUNT_CERT_URL"],
      universe_domain: "googleapis.com"
    }

    credentials_path = Rails.root.join("config/credentials")

    # Create the directory if it doesn't exist
    unless File.directory?(credentials_path)
      FileUtils.mkdir_p(credentials_path)
    end

    File.open("#{credentials_path}/#{project.key.downcase}_google_service_account.json", "w") do |file|
      file.write(JSON.pretty_generate(credentials))
    end
  end
  # rubocop:enable Metrics/AbcSize

  def initialize(project)
    super(project)

    @credentials_file_path = Rails.root.join("config/credentials/#{project.key.downcase}_google_service_account.json")

    return unless File.exist?(credentials_file_path)

    @credentials_file = File.open(credentials_file_path)
  end

  # Upload a file to Google Drive. It will return a hash with the following
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
  # @param file_name [String] The name of the file.
  # @param options [Hash] Additional options
  #
  # For now, all options are ignored by this service.
  #
  # Google Drive API does not allow us to upload files directly from a URL, so
  # it will first download the file into the `public/files` folder (which is
  # already on the .gitignore), and only then upload the file to the cloud.
  #
  # @return [Hash, nil] The response from the service or nil if the service is
  #   not configured.
  #
  # @example Upload a file to Google Drive
  #   google_drive_service = GoogleDriveService.new(project)
  #   google_drive_service.upload(url: "https://example.com/image.jpg")
  #
  # @example Upload a file with a different name to Google Drive
  #   google_drive_service = GoogleDriveService.new(project)
  #   google_drive_service.upload(
  #     url: "https://example.com/image.jpg",
  #     file_name: "my-file.jpg"
  #   )
  # rubocop:disable Lint/UnusedMethodArgument
  def upload(url:, file_name: nil, options: {})
    return unless configured?

    local_file_path = download_file(url: url)

    response = upload_local_file(
      local_file_path: local_file_path,
      file_name: file_name
    ).as_json

    folder_id = project.env["GOOGLE_SERVICE_REMOTE_FOLDER_ID"]
    folder = folder_id ? "ID #{folder_id}" : ""

    parse_response(url: "", folder: folder, response: response)
  end
  # rubocop:enable Lint/UnusedMethodArgument

  private

  # https://github.com/googleapis/google-auth-library-ruby
  def authorization
    @authorization ||=
      Google::Auth::ServiceAccountCredentials
        .make_creds(json_key_io: credentials_file, scope: API_SCOPE)
        .tap(&:fetch_access_token!)
  end

  def configured?
    @errors = []

    return true if credentials_file.present?

    @errors << "Missing credentials file at #{credentials_file_path}"

    false
  end

  def download_file(url:, save_path: Rails.public_path.join("files"))
    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    raise "Error: Unable to fetch the file. Response code #{response.code}" unless response.code == "200"

    file_name = extract_file_name_from_url(url, save_path)
    full_path = File.join(save_path, file_name)

    # Create the directory if it doesn't exist
    unless File.directory?(save_path)
      FileUtils.mkdir_p(save_path)
    end

    File.open(full_path, "wb") { |file| file.write(response.body) }

    full_path
  end

  def drive
    @drive ||= Google::Apis::DriveV3::DriveService.new.tap do |drive|
      drive.authorization = authorization
    end
  end

  def extract_file_name_from_url(url, folder_path)
    file_name_with_extension = File.basename(url)
    file_path = File.join(folder_path, file_name_with_extension)

    return file_name_with_extension unless File.exist?(file_path)

    extension = File.extname(file_name_with_extension)
    file_name_without_extension = File.basename(file_name_with_extension, extension)
    timestamp = Time.current.strftime("%Y%m%d%H%M%S")

    "#{file_name_without_extension}_#{timestamp}#{extension}"
  end

  # https://github.com/googleapis/google-api-ruby-client#simple-rest-clients-for-google-apis
  def upload_local_file(local_file_path:, file_name: nil)
    return unless local_file_path

    folder_id = project.env["GOOGLE_SERVICE_REMOTE_FOLDER_ID"]

    metadata = {
      name: file_name || File.basename(local_file_path),
      parents: [folder_id]
    }

    response = drive.create_file(
      metadata,
      upload_source: local_file_path,
      supports_all_drives: true
    )

    response.as_json
  end
end
