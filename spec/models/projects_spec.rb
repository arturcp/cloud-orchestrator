RSpec.describe Projects do
  before do
    stub_const("ENV", EnvHelper.envs)
    described_class.load
  end

  describe ".list" do
    it "returns a list of available projects" do
      expect(described_class.list.map(&:name))
        .to eq(["Project", "Other Project"])
    end
  end

  describe ".get_by_token" do
    it "returns the project when token is valid" do
      project = described_class
        .get_by_token("60f32233-d68f-4fd0-ab92-d57fa3d437f9")

      expect(project.name).to eq("Project")
      expect(project.key).to eq("PROJECT")
    end
  end

  it "returns nil when token is valid" do
    project = described_class.get_by_token("some-invalid-token")

    expect(project).to be_nil
  end
end
