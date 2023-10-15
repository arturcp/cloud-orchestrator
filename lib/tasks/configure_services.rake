namespace :cloud_orchestrator do
  desc "Configure all services for cloud orchestrator"
  task configure_services: :environment do
    def log(message)
      Rails.logger.info message
      puts message
    end

    ServiceFactory::SERVICES.each do |service_name, service|
      log "Configuring #{service_name} for..."
      Projects.list.each do |project|
        log "  * #{project.name}"
        service.configure(project)
      end

      log ""
    end
  end
end
