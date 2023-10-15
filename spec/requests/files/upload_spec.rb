RSpec.describe FilesController, type: :request do
  describe "POST /upload" do
    let(:project) { Project.new("Project") }
    let(:service) { CloudService.new(project) }
    let(:url) { "https://some-url.com/image.jpg" }

    before do
      stub_const("ENV", EnvHelper.envs)
      Projects.load

      allow(service).to receive(:upload).and_return(nil)
      allow(ServiceFactory).to receive(:build).and_return(service)
    end

    context "when service is not valid" do
      before do
        allow(service).to receive(:errors).and_return(["some error"])
      end

      it "returns unprocessable entity" do
        post upload_path, params: { service: "CloudService", url: url }, headers: {"X-Api-Key" => "60f32233-d68f-4fd0-ab92-d57fa3d437f9"}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq(["some error"].to_json)
      end
    end

    context "when service is valid" do
      before do
        allow(service).to receive(:upload).and_return({
          folder: "folder",
          project: "My Project",
          response: "response",
          service: "CloudService",
          url: "url"
        })
      end

      it "returns success" do
        post upload_path, params: { service: "CloudService", url: url }, headers: {"X-Api-Key" => "60f32233-d68f-4fd0-ab92-d57fa3d437f9"}
        expect(response).to have_http_status(:success)
        expect(response.body).to eq({
          folder: "folder",
          project: "My Project",
          response: "response",
          service: "CloudService",
          url: "url"
        }.to_json)
      end
    end
  end
end
