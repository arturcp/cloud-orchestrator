RSpec.describe ProjectHash do
  let(:hash) do
    {
      "PROJECT_KEY" => "123",
      "PROJECT_TOKEN" => "1dc6aa48-f670-49d2-aeb7-5f5ebac38b40"
    }
  end

  subject(:project_hash) { described_class.new("PROJECT", hash) }

  it "saves the parameters on the initializer" do
    expect(project_hash.project_key).to eq("PROJECT")
    expect(project_hash.hash).to eq(hash)
  end

  it "access the value without the project name prefix" do
    expect(project_hash["KEY"]).to eq("123")
    expect(project_hash["TOKEN"]).to eq("1dc6aa48-f670-49d2-aeb7-5f5ebac38b40")
  end
end
