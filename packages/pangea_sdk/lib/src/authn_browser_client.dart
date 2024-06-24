// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../pangea_sdk.dart';

class PangeaAuthNBrowser extends InAppBrowser {
  late String redirectURL;
  late Function onLoginSuccess;

  PangeaAuthNBrowser(
      {required String redirectUri,
      required Function onSuccess,
      int? windowId,
      UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts) {
    redirectURL = redirectUri;
    onLoginSuccess = onSuccess;
  }

  @override
  Future onBrowserCreated() async {
    print('\n\nBrowser Created!\n\n');
  }

  @override
  Future onLoadStart(url) async {
    print('Started $url');
  }

  @override
  Future onLoadStop(url) async {
    print('Stopped $url');
    pullToRefreshController?.endRefreshing();
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    print('Cant load ${request.url}.. Error: ${error.description}');
    // onError(request.url, 0, error.description);
  }

  @override
  Future<PermissionResponse> onPermissionRequest(permissionRequest) async {
    return PermissionResponse(
        resources: permissionRequest.resources,
        action: PermissionResponseAction.GRANT);
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    print('Error occured $url: $code, $message');
    // onError(url, code, message);
  }

  @override
  void onProgressChanged(progress) {
    print('Progress: $progress');
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
  }

  @override
  void onExit() {
    print('Browser closed!');
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    print('\n\nOverride ${navigationAction.request.url}\n\n');
    if (navigationAction.request.url.toString().startsWith(redirectURL)) {
      if (navigationAction.request.url?.queryParameters != null &&
          navigationAction.request.url!.queryParameters.containsKey('code')) {
        String? code = navigationAction.request.url?.queryParameters['code'];
        String? state = navigationAction.request.url?.queryParameters['state'];

        onLoginSuccess(code, state);
        return NavigationActionPolicy.CANCEL;
      }
    }
    return NavigationActionPolicy.ALLOW;
  }
}

class AuthNBrowserClient extends AuthNClient {
  late PangeaAuthNBrowser _browser;

  bool autoRefreshTokens = true;
  Session? _session;
  //  Create storage
  final storage = const FlutterSecureStorage();

  final StreamController<Session?> _sessionStream =
      StreamController<Session?>.broadcast();

  get userBroadcastStream => _sessionStream.stream.asBroadcastStream();

  get session => _session;

  Timer? _currentRefreshTime;

  AuthNBrowserClient({required ClientConfig config}) : super(config) {
    _browser = PangeaAuthNBrowser(
      redirectUri: config.callbackUri!,
      onSuccess: handleLoginSuccess,
    );
    _init();
  }

  void _init() async {
    var storedData = await storage.read(key: USER_STORAGE_KEY);

    if (storedData != null) {
      setUserData(json.decode(storedData));
    }
  }

  void setUserData(data, [bool store = false]) {
    _session = Session.fromJson(data);
    _sessionStream.add(_session);

    // Check if we have a refresh token
    if (autoRefreshTokens &&
        _session != null &&
        _session?.refreshToken.token != null) {
      var expiryTime = DateTime.tryParse(_session?.userToken.expire ?? '');
      print("Expires in $expiryTime Now: ${DateTime.now().toUtc()}");
      if (expiryTime != null) {
        var duration = expiryTime
            .add(const Duration(seconds: -30))
            .difference(DateTime.now().toUtc());

        // Is it too late to schedule a timer? then refresh it now
        if (duration.inSeconds < 0) {
          refreshSession(_session!.refreshToken.token);
        }

        if (_currentRefreshTime != null) {
          _currentRefreshTime?.cancel();
        }

        _currentRefreshTime =
            Timer(duration, () => refreshSession(_session!.refreshToken.token));
      }
    } else {
      clearUserData();
    }

    if (store) {
      print('Storing new data');
      storage.write(key: USER_STORAGE_KEY, value: json.encode(data));
    }
  }

  void clearUserData() {
    storage.delete(key: USER_STORAGE_KEY);

    // Cancel the refresh timer
    if (_currentRefreshTime != null) {
      _currentRefreshTime?.cancel();
    }

    _session = null;
    _sessionStream.add(null);
  }

  Future<ClientResponse> refreshSession(String token) async {
    print('Refreshing session: $token');
    final Map<String, dynamic> payload = {
      'refresh_token': token,
    };
    var response = await post('client/session/refresh', payload);

    if (response.success && response.response.result != null) {
      setUserData(response.response.result, true);
    } else {
      print('Error refreshing session: ${response.response}');
      clearUserData();
    }

    return response;
  }

  void handleLoginSuccess(String code, String state) async {
    _browser.close();
    try {
      ClientResponse userInfo = await userinfo(code);
      if (userInfo.success && userInfo.response?.result != null) {
        setUserData(userInfo.response.result, true);
      } else {
        print(
            'Incompatible response from the server ${jsonEncode(userInfo.response?.result)}');
      }
    } catch (e) {
      print('Error getting userinfo: $e\n');
    }
  }

  void handleLoginError(String url, int code, String description) {
    print('Error loading $url\n');
    print('code: $code\n');
    print('state: $description\n');
  }

  void redirectToLogin() async {
    if (config.hostedLoginUri != null) {
      var settings = InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            hideToolbarTop: true,
            hideToolbarBottom: true,
            hideCloseButton: false,
            presentationStyle: ModalPresentationStyle.OVER_FULL_SCREEN,
          ),
          webViewSettings: InAppWebViewSettings(
            userAgent: 'random',
            javaScriptEnabled: true,
            isInspectable: kDebugMode,
            useShouldOverrideUrlLoading: true,
            useOnLoadResource: true,
          ));

      _browser.openUrlRequest(
        urlRequest: URLRequest(url: WebUri(config.hostedLoginUri!)),
        settings: settings,
      );
    }
  }
}
