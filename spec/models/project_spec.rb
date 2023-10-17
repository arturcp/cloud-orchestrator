RSpec.describe Project do
  before do
    stub_const("ENV", EnvHelper.envs)
  end

  it "sets the key, name, and env_vars" do
    project = described_class.new("Project")

    expect(project.key).to eq("PROJECT")
    expect(project.name).to eq("Project")
    expect(project.env_vars).to eq({
      "PROJECT_CLOUD_ORCHESTRATOR_TOKEN" => "60f32233-d68f-4fd0-ab92-d57fa3d437f9",
      "PROJECT_PUBLIC_KEY" => "98765",
      "PROJECT_SECRET_KEY" => "12334"
    })
  end

  describe "#env" do
    it "returns a ProjectHash that access the envs without the project name prefix" do
      project = described_class.new("Project")

      expect(project.env).to be_a(ProjectHash)
      expect(project.env["PUBLIC_KEY"]).to eq("98765")
      expect(project.env["SECRET_KEY"]).to eq("12334")
    end
  end
end
