RSpec.describe GoogleDriveService, "#upload" do
  subject(:service) { described_class.new(project) }

  let(:url) { "https://some-url.com/image.jpg" }
  let(:project) { Project.new("My Project") }

  context "when google drive is configured" do
    before do
      allow(service).to receive(:configured?).and_return(true)
      allow(service).to receive(:download_file).with(url: url).and_return("some-path")
      allow(service).to receive(:authorization).and_return(double)

      allow_any_instance_of(Google::Apis::DriveV3::DriveService)
        .to receive(:create_file)
        .and_return({
          "id" => "1Ms__LC_bck92J63C-qjXCPKu3Wr8K784",
          "kind" => "drive#file",
          "mime_type" => "text/pdf",
          "name" => "outubro.pdf"
        })
    end

    it "uploads the file using GoogleDrive gem" do
      response = service.upload(url: url, file_name: "file_name.jpg")

      expect(response).to eq({
        folder: "",
        project: "My Project",
        response: {
          "id" => "1Ms__LC_bck92J63C-qjXCPKu3Wr8K784",
          "kind" => "drive#file",
          "mime_type" => "text/pdf",
          "name" => "outubro.pdf"
        },
        service: "GoogleDriveService",
        url: ""
      })
    end
  end

  context "when google drive is not configured" do
    it "returns false when credentials file is not present" do
      expect(service.upload(url: url)).to be_nil
      expect(service.errors).to eq(["Missing credentials file at #{service.credentials_file_path}"])
    end
  end

  context "when download fails" do
    before do
      allow(service).to receive(:configured?).and_return(true)
      allow(service).to receive(:authorization).and_return(double)
    end

    it "raises an error" do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPNotFound.new)

      expect { service.upload(url: url) }
        .to raise_error("Error: Unable to fetch the file. Response code 404")
    end
  end
end
