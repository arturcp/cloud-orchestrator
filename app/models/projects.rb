require_relative "project"

class Projects
  def self.load
    project_names = ENV["PROJECTS"].split(",")

    @projects = project_names.each_with_object({}) do |project_name, hash|
      project_name = project_name.strip.split.map(&:capitalize).join(" ")
      project = Project.new(project_name)

      next unless project.valid?

      hash[project.cloud_orchestrator_token] = project
    end
  end

  def self.get_by_token(token)
    @projects[token]
  end

  def self.list
    @projects.map { |_, project| project }
  end
end
