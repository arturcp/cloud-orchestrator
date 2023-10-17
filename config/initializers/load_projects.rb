require_relative "../../app/models/projects"

Projects.load unless Rails.env.test?
