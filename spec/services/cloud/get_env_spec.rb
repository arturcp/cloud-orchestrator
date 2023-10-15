RSpec.describe CloudService, "#get_env" do
  let(:project) { Project.new("My Project") }
  subject(:service) { described_class.new(project) }

  context "when environment variable is set" do
    before do
      stub_const("ENV", { "MY_PROJECT_KEY" => "some-value" })
    end

    it "returns the value" do
      expect(service.get_env("KEY")).to eq("some-value")
      expect(service.errors).to be_empty
    end
  end

  context "when environment variable is not set" do
    it "returns nil" do
      expect(service.get_env("INVALID_KEY")).to be_nil
      expect(service.errors).to eq(["Missing MY_PROJECT_INVALID_KEY environment variable"])
    end
  end
end
