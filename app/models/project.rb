require_relative "project_hash"

class Project
  attr_reader :name, :key, :env_vars

  def initialize(name)
    @name = name
    @key = name.parameterize(separator: "_").upcase
    @env_vars = ENV.select { |k, _| k.start_with?("#{key}_") }
  end

  def env
    ProjectHash.new(key, env_vars)
  end

  def cloud_orchestrator_token
    ENV["#{key}_CLOUD_ORCHESTRATOR_TOKEN"]
  end

  def valid?
    cloud_orchestrator_token.present?
  end
end
