# AuthN Demo

An example flutter project showing how to use add authentication to your app with using Pangea AuthN service thru flutter_pangea SDK.

## About AuthN

AuthN allows you to build a cloud-based authentication flow to help your login, session, and user management align with your security requirements while matching the look and feel of your app.

## Implementation

This example application utilizes [Pangea Hosted Login pages](https://pangea.cloud/docs/authn/hosted-login/) which are loaded in an in-app-browser window.

The app captures the token in the redirect URL when the user successfully completes the flow. The token is then saved in a session on the device and can be used later.

## Getting Started

- Copy `env.json.template` file to `env.json` which will be read by the proceeding commands
- You need to create a Pangea AuthN account, and go to https://console.pangea.cloud/ for configuring your projects
- Create a project
- Enable the AuthN service and configure it per your business requirements
- Go to https://console.pangea.cloud/service/authn url and get the necessary values for replacing the placeholders in the `env.json` file

## Run locally

Use this command to start the Flutter app locally or in the simulator with the proper environment variables: `flutter run --dart-define-from-file=env.json`