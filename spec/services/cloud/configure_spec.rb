RSpec.describe CloudService, ".configure" do
  let(:project) { Project.new("My Project") }

  it { expect(described_class.configure(project)).to be_nil }
end
