require_relative "project_hash"

class Project
  attr_reader :name, :key, :env_vars

  def initialize(name)
    @name = name
    @key = name.parameterize(separator: "_").upcase
    @env_vars = ENV.select { |k, _| k.start_with?("#{key}_") }
  end

  # This method will return a hash with all the environment variables for the
  # project. It will also remove the key from the variable name, so it is easier
  # to use them.
  #
  # For example, if the project key is `MY_PROJECT`, the environment variable
  # `MY_PROJECT_CLOUD_ORCHESTRATOR_TOKEN` will be returned as
  # `CLOUD_ORCHESTRATOR_TOKEN`.
  #
  # @return [ProjectHash] A hash with all the environment variables for the
  #   project.
  #
  # @example Get the environment variables for a project
  #   project = Project.new("My Project")
  #   project.env["CLOUD_ORCHESTRATOR_TOKEN"]
  def env
    ProjectHash.new(key, env_vars)
  end

  def cloud_orchestrator_token
    ENV["#{key}_CLOUD_ORCHESTRATOR_TOKEN"]
  end

  # This method will return true if the project has a cloud orchestrator token.
  # It is used to filter out projects that are not configured.
  #
  # @return [Boolean] True if the project has a cloud orchestrator token.
  #
  # @example Check if a project is valid
  #   project = Project.new("My Project")
  #   project.valid?
  def valid?
    cloud_orchestrator_token.present?
  end
end
