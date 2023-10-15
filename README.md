# Cloud Orchestrator

Tired of configuring cloud resources manually on each of your projects? To setup S3, Google Drive, Dropbox...

This project is for you! It aims to provide a simple API to rule them all, you will no longer need to worry about credentials, OAuth, configuration and so on. Just make a REST API call and you're done!

# Google Drive

To configure Google Drive credentials, you need to folllow these steps:

1. Access [Google Developer Console](https://console.developers.google.com/)
2. Create a project (our project is `Make My Date Backups`)
3. Enable the Google Drive API for your project
4. Create service credentials:
   a) https://www.youtube.com/watch?v=asrCdWFrF0A
   b) https://alvinrapada.medium.com/getting-google-drive-images-google-drive-api-with-elixir-bbb662dfdee0
5. Share the folder on Drive with the email account created on the previous step

To generate the credentials json file on the config folder you need to run a rake task. First, make sure you have all your env vars set with the credentials you got from the steps above. Then, run:

```
bin/rake cloud_orchestrator:create_google_credentials
```

# Cloudinary

documentation: https://cloudinary.com/documentation/ruby_rails_quickstart

# Dependencies

* Google Drive API gem: https://github.com/googleapis/google-api-ruby-client#simple-rest-clients-for-google-apis
* Google Auth gem: https://github.com/googleapis/google-auth-library-ruby
