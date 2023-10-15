class CloudService
  attr_reader :errors, :project

  def self.configure(_project); end

  def initialize(project)
    @project = project
    @errors = []
  end

  def upload(url:, file_name: nil, options: {})
    raise NotImplementedError
  end

  def get_env(key)
    value = project.env[key]
    errors << "Missing #{project.key}_#{key} environment variable" unless value

    value
  end

  def parse_response(folder:, url:, response:)
    {
      project: project.name,
      folder: folder,
      url: url,
      service: self::class.name,
      response: response
    }
  end
end
