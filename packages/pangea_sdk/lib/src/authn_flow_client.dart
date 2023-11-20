// // ignore_for_file: constant_identifier_names, non_constant_identifier_names
// import 'dart:async';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'authn_client.dart';
// import 'authn_flow_types.dart';
// import 'types.dart';

// class AuthNFlowClient extends AuthNClient {
//   Map<String, dynamic> _flowState = {...DEFAULT_FLOW_STATE};
//   Map<String, dynamic> options = {...DEFAULT_FLOW_OPTIONS};
//   bool autoRefreshTokens = true;

//   // Capabilities of the provider, like supported social providers etc
//   ProviderFeatureSet? _providerFeatureSet;

//   Session? _session;

// // Create storage
//   final storage = const FlutterSecureStorage();

//   // We have three streams, one for flow changes, one for user changes, and one for provider changes
//   final StreamController<Map<String, dynamic>?> _flowStream =
//       StreamController<Map<String, dynamic>?>.broadcast();

//   final StreamController<Session?> _sessionStream =
//       StreamController<Session?>.broadcast();

//   final StreamController<ProviderFeatureSet?> _providerStream =
//       StreamController<ProviderFeatureSet?>.broadcast();

//   Timer? _currentRefreshTime;

//   AuthNFlowClient(
//       {required ClientConfig config,
//       Map<String, dynamic>? options,
//       bool autoRefreshTokens = true})
//       : super(config) {
//     autoRefreshTokens = autoRefreshTokens;
//     if (options != null) {
//       this.options = {
//         ...DEFAULT_FLOW_OPTIONS,
//         ...options,
//       };
//     }

//     _flowState = {
//       ...DEFAULT_FLOW_STATE,
//     };

//     _init();
//   }

//   get userBroadcastStream => _sessionStream.stream.asBroadcastStream();
//   get providerStream => _providerStream.stream.asBroadcastStream();
//   get flowStream => _flowStream.stream.asBroadcastStream();

//   get session => _session;
//   get providerFeatureSet => _providerFeatureSet;
//   get flowState => _flowState;

//   void _init() async {
//     var storedData = await storage.read(key: USER_STORAGE_KEY);

//     if (storedData != null) {
//       setUserData(json.decode(storedData));
//     }

//     _initCapabilities();
//   }

//   void setUserData(data, [bool store = false]) {
//     _session = Session.fromJson(data);
//     _sessionStream.add(_session);

//     // Check if we have a refresh token
//     if (autoRefreshTokens &&
//         _session != null &&
//         _session?.refreshToken.token != null) {
//       var expiryTime = DateTime.tryParse(_session?.userToken.expire ?? '');
//       if (expiryTime != null) {
//         var duration = expiryTime
//             .add(const Duration(seconds: -30))
//             .difference(DateTime.now().toUtc());

//         // Is it too late to schedule a timer? the refresh it now
//         if (duration.inSeconds < 0) {
//           refreshSession(_session!.refreshToken.token);
//         }

//         if (_currentRefreshTime != null) {
//           _currentRefreshTime?.cancel();
//         }

//         _currentRefreshTime =
//             Timer(duration, () => refreshSession(_session!.refreshToken.token));
//       }
//     } else {
//       clearUserData();
//     }

//     if (store) {
//       storage.write(key: USER_STORAGE_KEY, value: json.encode(data));
//     }
//   }

//   void clearUserData() {
//     storage.delete(key: USER_STORAGE_KEY);

//     // Cancel the refresh timer
//     if (_currentRefreshTime != null) {
//       _currentRefreshTime?.cancel();
//     }

//     _session = null;
//     _sessionStream.add(null);
//   }

//   void resetFlow() {
//     _flowState = {...DEFAULT_FLOW_STATE};
//     emitFlowStateChange();
//   }

//   // we are making an empty start call to get the capabilities of the service
//   void _initCapabilities() async {
//     var response = await start({});

//     if (response.success && response.response?['result'] != null) {
//       _providerFeatureSet =
//           ProviderFeatureSet.fromJson(response.response['result']);
//       _providerStream.add(_providerFeatureSet);
//     }
//   }

//   void emitFlowStateChange() {
//     _flowStream.add(_flowState);
//   }

//   Future<ClientResponse> start(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.START.stringValue}';
//     final flowTypes = [];

//     if (options['signup']) {
//       flowTypes.add('signup');
//     }
//     if (options['signin']) {
//       flowTypes.add('signin');
//     }
//     final payload = {
//       'cb_uri': config.callbackUri,
//       'flow_types': flowTypes,
//     };
//     if (data['email'] != null) {
//       payload['email'] = data['email'];
//     }

//     final response = await post(path, payload, false);

//     if (response.success) {
//       if (payload['email'] != null) {
//         _flowState['step'] = response.response['result']['next_step'];
//         _flowState['email'] = payload['email'] as String?;

//         if (response.response['result']['verify_social'] != null) {
//           _flowState['verifyProvider'] =
//               response.response['result']['verify_social'];
//         }
//       } else {
//         if (response.response['result']['signup.password_signup'] == null) {
//           _flowState['passwordSignup'] = true;
//         }
//         if (response.response['result']['signup.social_signup'] != null) {
//           _flowState['socialSignup'] =
//               response.response['result']['signup.social_signup'];
//         }
//       }
//       _flowState['flowId'] = response.response['result']['flow_id'];
//       if (response.response['result']['verify_captcha.site_key'] != null) {
//         _flowState['recaptchaKey'] =
//             response.response['result']['verify_captcha.site_key'];
//       }

//       emitFlowStateChange();
//     }
//     return response;
//   }

//   Future<ClientResponse> signupPassword(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.SIGNUP_PASSWORD.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//       'first_name': data['first_name'],
//       'last_name': data['last_name'],
//       'password': data['password'],
//     };
//     return await post(path, payload);
//   }

//   Future<ClientResponse> signupSocial(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.SIGNUP_SOCIAL.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//       'cb_code': data['cb_code'],
//       'cb_flowState': data['cb_flowState'],
//     };
//     return await post(path, payload);
//   }

//   Future<ClientResponse> verifySocial(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.VERIFY_SOCIAL.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//       'cb_code': data['cb_code'],
//       'cb_flowState': data['cb_flowState'],
//     };
//     return await post(path, payload);
//   }

//   Future<ClientResponse> verifyPassword(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.VERIFY_PASSWORD.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//     };
//     if (data['reset'] != null) {
//       payload['reset'] = true;
//     } else {
//       payload['password'] = data['password'];
//     }
//     return await post(path, payload);
//   }

//   Future<ClientResponse> verifyCaptcha(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.VERIFY_CAPTCHA.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//       'code': data['code'],
//     };
//     return await post(path, payload);
//   }

//   Future<ClientResponse> verifyEmail(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.VERIFY_EMAIL.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//       'cb_code': data['cb_code'],
//       'cb_flowState': data['cb_flowState'],
//     };
//     return await post(path, payload);
//   }

//   Future<ClientResponse> enrollMfaStart(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.ENROLL_MFA_START.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//       'mfa_provider': data['mfa_provider'],
//     };
//     if (data['mfa_provider'] == 'sms_otp' && data['phone'] != null) {
//       payload['phone'] = data['phone'];
//     }
//     final response = await post(path, payload);
//     if (response.success) {
//       if (response.response.result.enroll_mfa_complete.totp_secret.qr_image !=
//           null) {
//         flowState['qrCode'] =
//             response.response.result.enroll_mfa_complete.totp_secret.qr_image;
//       }
//       _flowState['step'] = response.response.result.next_step;
//       emitFlowStateChange();
//     }
//     return response;
//   }

//   Future<ClientResponse> enrollMfaComplete(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.ENROLL_MFA_COMPLETE.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//     };
//     if (data['cancel'] != null && data['cancel'] == true) {
//       payload['cancel'] = true;
//     } else {
//       payload['code'] = data['code'];
//     }
//     return await post(path, payload);
//   }

//   Future<ClientResponse> verifyMfaStart(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.VERIFY_MFA_START.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//       'mfa_provider': data['mfa_provider'],
//     };
//     return await post(path, payload);
//   }

//   Future<ClientResponse> verifyMfaComplete(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.VERIFY_MFA_COMPLETE.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//     };
//     if (data['cancel'] != null && data['cancel'] == true) {
//       payload['cancel'] = true;
//     } else {
//       payload['code'] = data['code'];
//     }
//     return await post(path, payload);
//   }

//   Future<ClientResponse> resetPassword(Map<String, dynamic> data) async {
//     final path = 'flow/${FlowStep.RESET_PASSWORD.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//     };
//     if (data['cancel'] != null && data['cancel'] == true) {
//       payload['cancel'] = true;
//     } else {
//       payload['password'] = data['password'];
//       payload['cb_code'] = data['cb_code'];
//       payload['cb_flowState'] = data['cb_flowState'];
//     }
//     return await post(path, payload);
//   }

//   Future<ClientResponse> complete() async {
//     final path = 'flow/${FlowStep.COMPLETE.stringValue}';
//     final Map<String, dynamic> payload = {
//       'flow_id': _flowState['flowId'],
//     };
//     var response = await post(path, payload);

//     if (response.success && response.response?['result'] != null) {
//       setUserData(response.response['result'], true);
//     }
//     return response;
//   }

//   Future<ClientResponse> check(String token) async {
//     final Map<String, dynamic> payload = {
//       'token': token,
//     };
//     var response = await post('client/token/check', payload);
//     return response;
//   }

//   Future<ClientResponse> refreshSession(String token) async {
//     final Map<String, dynamic> payload = {
//       'refresh_token': token,
//     };
//     var response = await post('client/session/refresh', payload);

//     if (response.success && response.response?['result'] != null) {
//       setUserData(response.response['result'], true);
//     } else {
//       clearUserData();
//     }

//     return response;
//   }

//   @override
//   Future<ClientResponse> post(String path, Map<String, dynamic> data,
//       [bool updateflowState = true]) async {
//     try {
//       final Uri url =
//           Uri.parse('https://authn.${config.domain}/$API_VERSION/$path');

//       final headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${config.clientToken}'
//       };

//       final response = await http.post(
//         url,
//         body: json.encode(data),
//         headers: headers,
//       );
//       final success =
//           processResponse(json.decode(response.body), updateflowState);
//       if (_flowState['step'] == FlowStep.COMPLETE.stringValue) {
//         return await complete();
//       } else if (_flowState['step'] == FlowStep.VERIFY_MFA_START.stringValue) {
//         return await verifyMfaStart(
//             {'mfaProvider': _flowState['selectedMfa'] ?? ''});
//       } else if (_flowState['step'] == FlowStep.ENROLL_MFA_START.stringValue &&
//           _flowState['selectedMfa'] != 'sms_otp') {
//         return await enrollMfaStart(
//             {'mfaProvider': _flowState['selectedMfa'] ?? ''});
//       }
//       return ClientResponse(
//           success: success, response: json.decode(response.body));
//     } catch (err) {
//       return ClientResponse(success: false, response: getError(err));
//     }
//   }

//   bool processResponse(Map<String, dynamic> response,
//       [bool updateflowState = true]) {
//     var success = response['status'] == 'Success';
//     if (success && updateflowState) {
//       if (response['result']?['verify_mfa_start']?['mfa_providers'] != null) {
//         _flowState['mfaProviders'] =
//             response['result']?['verify_mfa_start']?['mfa_providers'] == null
//                 ? []
//                 : [...response['result']['verify_mfa_start']['mfa_providers']];
//       } else if (response['result']?['enroll_mfa_start']?['mfa_providers'] !=
//           null) {
//         _flowState['mfaProviders'] =
//             response['result']?['enroll_mfa_start']?['mfa_providers'] == null
//                 ? []
//                 : [
//                     ...response['result']?['enroll_mfa_start']?['mfa_providers']
//                   ];
//       }
//       if (_flowState['selectedMfa'] == null &&
//           _flowState['mfaProviders'].length > 0) {
//         _flowState['selectedMfa'] = _flowState['mfaProviders'][0];
//       }
//       if (response['result']['error'] != null) {
//         success = false;
//       }
//       _flowState['step'] = response['result']?['next_step'];
//       emitFlowStateChange();
//     } else if (!success &&
//         updateflowState &&
//         response['result']?['next_step'] != null) {
//       _flowState['step'] = response['result']['next_step'];
//       emitFlowStateChange();
//     }
//     return success;
//   }
// }
