class CloudService
  attr_reader :errors, :project

  # By default, services will do nothing then the configuration rake runs. If
  # you need to configure your service, override this method.
  #
  # The configuration rake is run with:
  #
  # `bin/rake cloud_orchestrator:configure_services`
  #
  # It will loop through all the available services and execute the `configure`
  # method. This is particularly useful when the service needs additional setup
  # after the user sets the environment variables.
  #
  # Check GoogleDriveService for an example.
  def self.configure(_project); end

  def initialize(project)
    @project = project
    @errors = []
  end

  def upload(url:, file_name: nil, options: {})
    raise NotImplementedError
  end

  # Every time you use get_env, an error will be added to the @errors variable
  # if the value is not set. This is useful to control the error messages that
  # the service will present the users in case an environment variable is
  # missing.
  def get_env(key)
    value = project.env[key]
    errors << "Missing #{project.key}_#{key} environment variable" unless value

    value
  end

  # All services should use the `parse_response` method to return the response.
  # It will include common information like the project name, the folder, the
  # url and the service name.
  def parse_response(folder:, url:, response:)
    {
      project: project.name,
      folder: folder,
      url: url,
      service: self.class.name,
      response: response
    }
  end
end
