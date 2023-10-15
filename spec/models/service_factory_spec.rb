RSpec.describe ServiceFactory do
  let(:project) { Project.new("Project") }

  describe ".build" do
    it "returns an instance of the default service when service name is invalid" do
      expect(described_class.build("invalid_service", project))
        .to be_a(ServiceFactory::DEFAULT_SERVICE)
    end

    it "returns an instance of the GoogleDriveService when service name google_drive" do
      expect(described_class.build("google_drive", project))
        .to be_a(GoogleDriveService)
    end

    it "returns an instance of the CloudinaryService when service name cloudinary" do
      expect(described_class.build("cloudinary", project))
        .to be_a(CloudinaryService)
    end
  end
end
