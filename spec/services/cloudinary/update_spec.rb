RSpec.describe CloudinaryService, "#upload" do
  let(:url) { "https://some-url.com/image.jpg" }
  let(:project) { Project.new("My Project") }
  subject(:service) { described_class.new(project) }

  it { expect(described_class.configure(project)).to be_nil }

  context "when cloudinary is configured" do
    before do
      allow(service).to receive(:configured?).and_return(true)
    end

    it "uploads the file using Cloudinary gem" do
      expect(Cloudinary::Uploader)
        .to receive(:upload).with(
          url,
          folder: "my-files",
          public_id: "file_name.jpg",
          display_name: "file_name.jpg"
        )
        .and_return({
          "url" => "https://some-url.com/image.jpg",
          "folder" => "my-files"
        })

      response = service.upload(url: url, file_name: "file_name.jpg",
        options: { remote_folder: "my-files" })

      expect(response).to eq({
        folder: "my-files",
        project: "My Project",
        response: {
          "folder" => "my-files",
          "url" => "https://some-url.com/image.jpg"
        },
        service: "CloudinaryService",
        url: "https://some-url.com/image.jpg"
      })
    end

    it "extracts the name of the file from the URL" do
      expect(Cloudinary::Uploader)
        .to receive(:upload).with(
          url,
          folder: "my-files",
          public_id: "image.jpg",
          display_name: "image.jpg"
        )
        .and_return({
          "url" => "https://some-url.com/image.jpg",
          "folder" => "my-files"
        })

      service.upload(url: url, options: { remote_folder: "my-files" })
    end

    it "uses an empty string when remote folder is not provided" do
      expect(Cloudinary::Uploader)
        .to receive(:upload).with(
          url,
          folder: "",
          public_id: "image.jpg",
          display_name: "image.jpg"
        )
        .and_return({
          "url" => "https://some-url.com/image.jpg",
          "folder" => ""
        })

      service.upload(url: url)
    end
  end

  context "when cloudinary is not configured" do
    it "returns nil and sets errors" do
      response = service.upload(url: url, file_name: "file_name.jpg",
        options: { remote_folder: "my-files" })

      expect(service.errors).to eq(
        [
          "Missing MY_PROJECT_CLOUDINARY_API_KEY environment variable",
          "Missing MY_PROJECT_CLOUDINARY_API_SECRET environment variable",
          "Missing MY_PROJECT_CLOUDINARY_PROJECT_NAME environment variable"
        ]
      )
      expect(response).to be_nil
    end
  end
end
