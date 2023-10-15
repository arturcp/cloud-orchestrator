class GoogleDriveService < CloudService
  API_SCOPE = "https://www.googleapis.com/auth/drive"

  attr_reader :credentials_file, :credentials_file_path

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

    File.open("config/credentials/#{project.key.downcase}_google_service_account.json", "w") do |file|
      file.write(JSON.pretty_generate(credentials))
    end
  end

  def initialize(project)
    super(project)

    @credentials_file_path = Rails.root.join("config/credentials/#{project.key.downcase}_google_service_account.json")

    if File.exist?(credentials_file_path)
      @credentials_file = File.open(credentials_file_path)
    end
  end

  def upload(url:, file_name: nil, options: {})
    return unless configured?

    local_file_path = download_file(url: url)

    response = upload_local_file(local_file_path: local_file_path,
      file_name: file_name).as_json

    folder_id = project.env["GOOGLE_SERVICE_REMOTE_FOLDER_ID"]
    folder = folder_id ? "ID #{folder_id}" : ""

    parse_response(url: "", folder: folder, response: response)
  end

  private

  # https://github.com/googleapis/google-auth-library-ruby
  def authorization
    @authorization ||= begin
      Google::Auth::ServiceAccountCredentials
        .make_creds(json_key_io: credentials_file, scope: API_SCOPE).tap do |authorizer|
          authorizer.fetch_access_token!
      end
    end
  end

  def configured?
    @errors = []

    return true if credentials_file.present?

    @errors << "Missing credentials file at #{credentials_file_path}"

    false
  end

  def download_file(url:, save_path: Rails.root.join("public/files"))
    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    if response.code == "200"
      file_name = extract_file_name_from_url(url, save_path)

      full_path = File.join(save_path, file_name)
      File.open(full_path, "wb") do |file|
        file.write(response.body)
      end

      full_path
    else
      raise "Error: Unable to fetch the file. Response code #{response.code}"
    end
  end

  def drive
    @drive ||= begin
      Google::Apis::DriveV3::DriveService.new.tap do |drive|
        drive.authorization = authorization
      end
    end
  end

  def extract_file_name_from_url(url, folder_path)
    file_name_with_extension = File.basename(url)
    file_path = File.join(folder_path, file_name_with_extension)

    if File.exist?(file_path)
      extension = File.extname(file_name_with_extension)
      file_name_without_extension = File.basename(file_name_with_extension, extension)
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")

      return "#{file_name_without_extension}_#{timestamp}#{extension}"

      return new_file_name
    else
      return file_name_with_extension
    end
  end

  # https://github.com/googleapis/google-api-ruby-client#simple-rest-clients-for-google-apis
  def upload_local_file(local_file_path:, content_type: "text/pdf", file_name: nil)
    return unless local_file_path

    folder_id = project.env["GOOGLE_SERVICE_REMOTE_FOLDER_ID"]

    metadata = {
      name: file_name || File.basename(local_file_path),
      parents: [folder_id]
    }

    response = drive.create_file(metadata, upload_source: local_file_path, content_type: content_type, supports_all_drives: true)

    response.as_json
  end
end
