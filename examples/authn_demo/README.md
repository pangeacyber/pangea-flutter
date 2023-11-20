# authn_demo

An example flutter project showing how to use add authentication to your app with using Pangea AuthN service thru flutter_pangea SDK.

## Getting Started

In order to start using Pangea AuthN service:

- You need to create a Pangea AuthN account, and go to https://console.pangea.cloud/ for configuring your projects
- Create a project
- Enable the AuthN service and configure it per your business requirements
- Go to https://console.pangea.cloud/service/authn url and get the necessary values for replacing the placeholders in the `service_locator.dart` file:

  The following placeholders should replaced:

  - clientToken: 'pcl_your_pangea_authn_client_token' // Get it from https://console.pangea.cloud/service/authn
  - domain: 'abc.def.pangea.cloud' // Get it from https://console.pangea.cloud/service/authn
  - callbackUri: 'http://localhost:57253' // Your local dev url
  - hostedLoginUri: 'https://pdn-your_hosted_login_page.pangea.cloud/authorize?state=xxxxxxxxxxxxx' // Get it from https://console.pangea.cloud/service/authn

Now that settings are in place, you can run the sample app and try it out.
