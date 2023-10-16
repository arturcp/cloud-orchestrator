RSpec.describe CloudService, "#parse_response" do
  subject(:service) { described_class.new(project) }

  let(:project) { Project.new("My Project") }

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
