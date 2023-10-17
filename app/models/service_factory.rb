class ServiceFactory
  DEFAULT_SERVICE = CloudinaryService
  SERVICES = {
    "google_drive" => GoogleDriveService,
    "cloudinary" => CloudinaryService
  }.freeze

  def self.build(service_name, project)
    SERVICES.fetch(service_name, DEFAULT_SERVICE).new(project)
  end
end
