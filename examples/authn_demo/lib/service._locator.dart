import 'package:pangea_sdk/pangea_sdk.dart';

late final AuthNBrowserClient authnBrowserClient;

// Service Locator: pattern and Dependedency Injection
void setupLocator() async {
  // init
  authnBrowserClient = AuthNBrowserClient(
    config: ClientConfig(
        clientToken: const String.fromEnvironment('PANGEA_CLIENT_TOKEN', defaultValue: 'no-value-provided'),
        domain: const String.fromEnvironment('PANGEA_DOMAIN', defaultValue: 'no-value-provided'),
        callbackUri: const String.fromEnvironment('PANGEA_AUTHN_CALLBACK_URI', defaultValue: 'no-value-provided'),
        hostedLoginUri: const String.fromEnvironment('PANGEA_AUTHN_HOSTED_LOGIN_URI', defaultValue: 'no-value-provided'),
    )
  );
}
