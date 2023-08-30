# Much To Do

Mobile application that allows for tasks needing to be done around the house to easily be tracked, prioritized, and filtered. While it is built using Flutter, a cross platform framework, all testing and executables are targeted to Android since I do not have a way currently of testing on iOS.

The mobile application connects to a REST API running on Express, and that API interacts with other Express microservices for long running operations (such as deleting all photos of a user).

## Prerequisites

Flutter is needed to build and run the mobile application.

Node.js is needed to run the API and microservices.

Google cloud CLI is needed to run the API and microservices locally.

Below environment variables must be set

- MuchToDo_Mongo__ConnectionString
- MuchToDo_Firebase__ProjectId
- MuchToDo_Firebase__TaskPhotoBucket
- GOOGLE_APPLICATION_CREDENTIALS

Ensure environment variable GOOGLE_APPLICATION_CREDENTIALS is pointed to `%APPDATA%\gcloud\application_default_credentials.json`

To switch locally between projects run the below commands:

`gcloud config set project <ProjectId>`

`gcloud auth application-default login`

## Deployment

To deploy the app you can deploy either in an IDE or command line using flutter.

The express APIs can be run using the `npm start` command. When testing locally on an Android emulator you have to use the a loopback address instead of localhost: `10.0.2.2`

To deploy the API to the cloud follow these steps:


## Authors

- Joshua Rapoport - *Creator and Lead Software Developer*
