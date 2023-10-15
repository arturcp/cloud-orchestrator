RSpec.describe CloudService, "#parse_response" do
  let(:project) { Project.new("My Project") }
  subject(:service) { described_class.new(project) }

  it "includes common attributes in the response" do
    response = service.parse_response(folder: "folder", url: "url", response: "response")
    expect(response).to eq({
      folder: "folder",
      project: "My Project",
      response: "response",
      service: "CloudService",
      url: "url"
    })
  end
end
