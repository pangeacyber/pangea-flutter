// // ignore_for_file: constant_identifier_names, non_constant_identifier_names, avoid_print

// // AuthNFlow types

// /*
//   Flow data types
// */
// class FlowStorage {
//   FlowStep? step;
//   String? flow_id;
//   String? email;
//   String? selected_mfa;
//   List<String>? mfa_providers;
//   String? recaptcha_key;
//   String? qr_code;
// }

// enum FlowStep {
//   START,
//   SIGNUP,
//   SIGNUP_PASSWORD,
//   SIGNUP_SOCIAL,
//   VERIFY_SOCIAL,
//   VERIFY_PASSWORD,
//   VERIFY_PASSWORD_RESET,
//   VERIFY_CAPTCHA,
//   VERIFY_EMAIL,
//   ENROLL_MFA_SELECT, // UI-only state
//   ENROLL_MFA_START,
//   ENROLL_MFA_COMPLETE,
//   VERIFY_MFA_SELECT, // UI-only state
//   VERIFY_MFA_START,
//   VERIFY_MFA_COMPLETE,
//   RESET_PASSWORD,
//   MFA_SELECT,
//   COMPLETE,
// }

// extension FlowStepExtension on FlowStep {
//   String get stringValue {
//     return toString().split('.').last.toLowerCase().replaceAll('_', '/');
//   }

//   FlowStep fromString(String value) {
//     return FlowStep.values.firstWhere((e) => e.stringValue == value);
//   }
// }

// const DEFAULT_FLOW_OPTIONS = {
//   'signin': true,
//   'signup': true,
// };

// const DEFAULT_FLOW_STATE = {
//   'step': FlowStep.START,
//   'flowId': '',
//   'email': '',
//   'selectedMfa': '',
//   'mfaProviders': [],
//   'cancelMfa': true,
//   'recaptchaKey': '',
//   'qrCode': '',
//   'passwordSignup': true,
//   'socialSignup': {},
//   'verifyProvider': {},
//   'redirectUri': '',
// };

// class ProviderFeatureSet {
//   bool hasGoogle;
//   bool hasGithub;

//   get hasSocialLogin => hasGoogle || hasGithub;

//   ProviderFeatureSet({required this.hasGoogle, required this.hasGithub});

//   factory ProviderFeatureSet.fromJson(Map<String, dynamic> data) {
//     List<dynamic> socialProviders =
//         data['signup']?['social_signup']?['providers'] ?? [];

//     final containsGoogle =
//         socialProviders.indexWhere((s) => s?['provider'] == 'google') > -1;
//     final containsGithub =
//         socialProviders.indexWhere((s) => s?['provider'] == 'github') > -1;

//     return ProviderFeatureSet(
//         hasGoogle: containsGoogle, hasGithub: containsGithub);
//   }
// }
