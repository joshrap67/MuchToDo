# Much To Do

Mobile application that allows for tasks needing to be done around the house to easily be tracked, prioritized, and filtered. While it is built using Flutter, a cross platform framework, all testing and executables are targeted to Android since I do not have a way currently of testing on iOS.

The mobile application connects to a REST API running on Express that runs in a Google Cloud Function instance.

Google Play Store requires a website to request for account deletion for GDPR compliance. I just did a quick and dirty react app to accomplish this. It is hosted on Github Pages and is accessible from [this link](https://joshrap67.github.io/MuchToDo/#/home).

## Prerequisites

Flutter is needed to build and run the mobile application.

Node.js is needed to run the API and deploy to GH Pages.

Google cloud CLI is needed to run the API locally.

Below environment variables must be set for the API

- MUCHTODO_MONGO__CONNECTIONSTRING
- MUCHTODO_FIREBASE__PROJECTID
- MUCHTODO_FIREBASE__TASKPHOTOBUCKET
- GOOGLE_APPLICATION_CREDENTIALS (locally)

There should be a corresponding .env file for these in the root directory of the service (e.g. in the same hierarchy of the package.json)

Ensure environment variable GOOGLE_APPLICATION_CREDENTIALS is pointed to `%APPDATA%\gcloud\application_default_credentials.json`

To switch locally between projects run the below commands:

`gcloud config set project <ProjectId>`

`gcloud auth application-default login`

## Deployment

To deploy the app you can deploy either in an IDE or command line using flutter.

The express APIs can be run using the `npm run start-local` command. This will require slight modification of the index.ts files to have express listen locally (as normally the express app is just passed into the google cloud function). When testing locally on an Android emulator you have to use the a loopback address instead of localhost: `10.0.2.2`

To deploy to Google Cloud Functions run this command in the directory of the desired service:
`firebase deploy --only functions`

To publish the GH pages website run `npm run deploy` in the directory.


## Authors

- Joshua Rapoport - *Creator and Lead Software Developer*
