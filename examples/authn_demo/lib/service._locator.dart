import 'package:pangea_sdk/pangea_sdk.dart';

late final AuthNBrowserClient authnBrowserClient;

// Service Locator: pattern and Dependedency Injection
void setupLocator() async {
  // init
  authnBrowserClient = AuthNBrowserClient(
    config: ClientConfig(
        clientToken:
            'pcl_your_pangea_authn_client_token', // Get it from https://console.pangea.cloud/service/authn
        domain:
            'abc.def.pangea.cloud', // Get it from https://console.pangea.cloud/service/authn
        callbackUri: 'http://localhost:57253', // Your local dev url
        hostedLoginUri:
            'https://pdn-your_hosted_login_page.pangea.cloud/authorize?state=xxxxxxxxxxxxx'), // Get it from https://console.pangea.cloud/service/authn
  );
}
