class ProjectHash
  attr_reader :hash, :project_key

  def initialize(project_key, hash)
    @project_key = project_key
    @hash = hash
  end

  def [](key)
    @hash["#{project_key}_#{key}"]
  end
end
