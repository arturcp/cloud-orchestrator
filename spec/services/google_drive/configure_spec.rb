RSpec.describe GoogleDriveService, ".configure" do
  let(:file) { double(write: nil) }
  let(:project_name) { "My Project" }
  let(:project) { Project.new(project_name) }

  before do
    stub_const("ENV", {
      "PROJECTS" => project_name,
      "MY_PROJECT_CLOUD_ORCHESTRATOR_TOKEN" => "60f32233-d68f-4fd0-ab92-d57fa3d437f9",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_PROJECT_ID" => "project id",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY_ID" => "private key id",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY" => "private key",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL" => "client email",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_CLIENT_ID" => "client id",
      "MY_PROJECT_GOOGLE_SERVICE_ACCOUNT_CERT_URL" => "cert url"
    })

    allow(File).to receive(:open).with("config/credentials/my_project_google_service_account.json", "w").and_yield(file)
  end

  it "creates a file with the credentials" do
    allow(JSON).to receive(:pretty_generate)

    described_class.configure(project)

    expect(JSON).to have_received(:pretty_generate).with({
      type: "service_account",
      project_id: "project id",
      private_key_id: "private key id",
      private_key: "private key",
      client_email: "client email",
      client_id: "client id",
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: "cert url",
      universe_domain: "googleapis.com"
    })
  end
end
