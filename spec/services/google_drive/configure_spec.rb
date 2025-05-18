RSpec.describe GoogleDriveService, ".configure" do
  let(:file) { instance_double(File, write: nil) }
  let(:project_name) { "My Project" }
  let(:project) { Project.new(project_name) }
  let(:credentials_path) { Rails.root.join("config/credentials") }
  let(:credentials_file_path) { File.join(credentials_path, "#{project.key.downcase}_google_service_account.json") }
  let(:private_key) { "-----BEGIN PRIVATE KEY-----\nprivate key\n-----END PRIVATE KEY-----" }
  let(:escaped_private_key) { "-----BEGIN PRIVATE KEY-----\\nprivate key\\n-----END PRIVATE KEY-----" }

  before do
    stub_const("ENV", {
      "PROJECTS" => project_name,
      "MY_PROJECT_CLOUD_ORCHESTRATOR_TOKEN" => "60f32233-d68f-4fd0-ab92-d57fa3d437f9",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_PROJECT_ID" => "project id",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY_ID" => "private key id",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY" => private_key,
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL" => "client email",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_CLIENT_ID" => "client id",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_CERT_URL" => "cert url"
    })

    allow(File).to receive(:open).with(credentials_file_path, "w").and_yield(file)
    allow(FileUtils).to receive(:mkdir_p)
  end

  it "creates the credentials directory if it doesn't exist" do
    allow(File).to receive(:directory?).with(credentials_path).and_return(false)

    described_class.configure(project)

    expect(FileUtils).to have_received(:mkdir_p).with(credentials_path)
  end

  it "writes the credentials file with the correct content" do
    allow(File).to receive(:directory?).with(credentials_path).and_return(true)

    described_class.configure(project)

    expect(file).to have_received(:write).with(
      include(escaped_private_key)
    )
  end

  it "includes all required fields in the credentials" do
    allow(File).to receive(:directory?).with(credentials_path).and_return(true)

    described_class.configure(project)

    expected_content = [
      '"type": "service_account"',
      '"project_id": "project id"',
      '"private_key_id": "private key id"',
      '"private_key": "' + escaped_private_key + '"',
      '"client_email": "client email"',
      '"client_id": "client id"',
      '"auth_uri": "https://accounts.google.com/o/oauth2/auth"',
      '"token_uri": "https://oauth2.googleapis.com/token"',
      '"auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"',
      '"client_x509_cert_url": "cert url"',
      '"universe_domain": "googleapis.com"'
    ]

    expected_content.each do |content|
      expect(file).to have_received(:write).with(include(content))
    end
  end
end
