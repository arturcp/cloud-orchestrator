# Cloud Orchestrator

Are you tired of manually configuring each cloud service, like S3, Google Drive, Dropbox, or Cloudinary, on each one of your projects?

This project is for you! It aims to provide a simple API to rule them all, you will no longer need to worry about credentials, OAuth, configurations, and so on. Just make a REST API call, and you are ready to go!

Each service will have its step instructions to configure it, but fear not: we are here to help. Here, you will find step-by-step instructions on how to get your credentials. This API allows for multiple projects, but for simplicity's sake, it does not use any database, the entire configuration is done via environment variables.

# Requirements

This project is built for:

* Ruby 3.2.2
* Rails 7.1.1


# Getting started

Once you clone this repository, you need to install the dependencies:

```
bundle install
```

Then, make a copy of the `.env.example` file and rename it to `.env`:

```
cp .env.example .env
```

This file contains all the environment variables you need to configure the services. The first variable you need to set is `PROJECTS`.

## PROJECTS environment variable

This is a comma-separated string with all the projects that use the Cloud Orchestrator. For example, if you have two projects, `Policies Service` and `Billing Service`, you need to set this variable to:


```
PROJECTS=Policies Service,Billing Service
```

Notice that there is no space around the commas.

From now on, all variables should be prefixed with the project name. For example, if you have a project called `Policies Service`, you will have a variable called `POLICIES_SERVICE_GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY_ID` if you decide to use the Google Drive service. Thus, if your Billing Service also uses Google Drive, you will have a variable called `BILLING_SERVICE_GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY_ID`.

But before going deep into each service's required variables, let's talk about the `CLOUD_ORCHESTRATOR_TOKEN` variable. To know which service is making the request, the client will have to include a special header in the request, called `X-API-KEY`.

When the Cloud Orchestrator project is first loaded, it will build a list of available services in memory using the list from the `PROJECTS` variable. For each service, it will find a Cloud Orchestrator Token using the service name as a prefix. A project called `Policies Service` **needs** to have a `POLICIES_SERVICE_CLOUD_ORCHESTRATOR_TOKEN` set.

This token can be any valid string. It will work as long as your requests send the very same string on the headers.

Once a request reaches the server, it will fetch the `X-API-KEY` header and compare it with the `<PROJECT_NAME>_CLOUD_ORCHESTRATOR_TOKEN` variables. If they match, the request will be processed using that service's environment variables. Otherwise, the server will return a `401 Unauthorized` response.

Let's see an example.

Imagine you have those two projects, `Policies Service` and `Billing Service`, and both of them use Cloudinary. You will have to set the following variables:

```
PROJECTS="Policies Service,Billing Service"

# Policies service
# ==============================================================================
POLICIES_SERVICE_CLOUD_ORCHESTRATOR_TOKEN=d92b1233-abc5-447b-88e7-4ef2a8cdfd67

POLICIES_SERVICE_CLOUDINARY_API_KEY=some-api-key
POLICIES_SERVICE_CLOUDINARY_API_SECRET=some-api-secret
POLICIES_SERVICE_CLOUDINARY_PROJECT_NAME=some-cloudinary-project-name

# Billing service
# ==============================================================================
BILLING_SERVICE_CLOUD_ORCHESTRATOR_TOKEN=187bd01c-1f51-4bea-823c-6dc9657ece42

BILLING_SERVICE_CLOUDINARY_API_KEY=some-other-api-key
BILLING_SERVICE_CLOUDINARY_API_SECRET=some-other-api-secret
BILLING_SERVICE_CLOUDINARY_PROJECT_NAME=some-other-cloudinary-project-name
```

Each service has its own configuration variables, you can find more information about each service in the sections below. Just remember to prefix them with the name of the project that will use them (use the project name, with underscores instead of spaces, and uppercase all letters).


# Google Drive

To configure Google Drive credentials, you need to follow these steps:

1. Access [Google Developer Console](https://console.developers.google.com/)
2. Create a project (for example `Policies Service`)
3. Enable the Google Drive API for your project
4. Create **service credentials**:
   a) https://www.youtube.com/watch?v=asrCdWFrF0A
   b) https://alvinrapada.medium.com/getting-google-drive-images-google-drive-api-with-elixir-bbb662dfdee0
5. Share the folder on your Google Drive with the email account created in the previous step.


Step 5 is important: when you create a service account, it has its own Google Drive space. When uploading files using the credentials, the files will be uploaded to this account's Google Drive, and you have no way to access them using any web interface. To make the files available to your own account, you need to share a folder from your personal Google Drive with the email account created in step 4.

To configure your project to use Google Drive, you will need to set these environment variables:

```
<PROJECT_NAME>_GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY_ID=
<PROJECT_NAME>_GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY=
<PROJECT_NAME>_GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL=
<PROJECT_NAME>_GOOGLE_SERVICE_ACCOUNT_CLIENT_ID=
<PROJECT_NAME>_GOOGLE_SERVICE_ACCOUNT_CERT_URL=
<PROJECT_NAME>_GOOGLE_SERVICE_ACCOUNT_PROJECT_ID=
<PROJECT_NAME>_GOOGLE_SERVICE_REMOTE_FOLDER_ID=
```

Once you create your service account credentials, download the file. You will find the information you need to set these variables on the JSON file you have just downloaded.

Replace `<PROJECT_NAME>` with the name of your project set on the `PROJECTS` environment variable. It needs to have underscores instead of spaces and have all letters in uppercase.


# Cloudinary

After creating your Cloudinary account, go to `settings` -> `Access Keys`. There, you will find your `API Key` and `API Secret`. If you don't see any credentials, you will need to create one using the `+ Generate New Access Key` button.

The name of the Cloudinary Service you will use on the environment variables is not the name you see on this page. Instead of that, go to `Account`, on the left menu, and find the project name under the `Cloud Name` table at the bottom of the page.

To configure your project to use Cloudinary, you will need to set these environment variables:

```
<PROJECT_NAME>_CLOUDINARY_API_KEY=
<PROJECT_NAME>_CLOUDINARY_API_SECRET=
<PROJECT_NAME>_CLOUDINARY_PROJECT_NAME=
```

Replace `<PROJECT_NAME>` with the name of your project set on the `PROJECTS` environment variable. It needs to have underscores instead of spaces and have all letters in uppercase.

# The variables are set, what now?

Some services require additional steps after setting the environment variables. For example, Google Drive requires you to create a credentials JSON file.

To make this as transparent as possible, each service has a self method named `configure`, that contains automatic instructions on how to configure the service. You don't need to worry about any of that, all you need to do is run a rake task already built in to configure all the services to all the projects you have (just remember to set the environment variables first).

```

To configure the services, just run the following rake task:

```
bin/rake cloud_orchestrator:configure_services
```

# Dependencies

* Google Drive API gem: https://github.com/googleapis/google-api-ruby-client#simple-rest-clients-for-google-apis
* Google Auth gem: https://github.com/googleapis/google-auth-library-ruby
