import 'package:flutter/foundation.dart';

class ClientConfig {
  String domain;
  String clientToken;
  String? callbackUri;
  String? hostedLoginUri;

  ClientConfig(
      {required this.domain,
      required this.clientToken,
      this.callbackUri,
      this.hostedLoginUri});
}

class ClientResponse {
  bool success;
  dynamic response;

  ClientResponse({required this.success, this.response});
}

class APIResponse {
  String status;
  String summary;
  dynamic result;

  APIResponse({required this.status, required this.summary, this.result});
}

class User {
  String id;
  String email;
  String? firstName;
  String? lastName;
  String? lastLoginTime;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.lastLoginTime,
  });

  factory User.fromSession(Session data) {
    return User(
        id: data.refreshToken.identity,
        email: data.refreshToken.email,
        firstName: data.refreshToken.profile?.firstName ?? '',
        lastName: data.refreshToken.profile?.lastName ?? '',
        lastLoginTime: data.refreshToken.profile?.lastLoginTime ?? '');
  }
}

class Profile {
  String? lastLoginTime;
  String? loginFrom;
  String? loginTime;
  String? userAgent;
  String? firstName;
  String? lastName;

  Profile({
    this.lastLoginTime,
    this.loginFrom,
    this.loginTime,
    this.userAgent,
    this.firstName,
    this.lastName,
  });

  factory Profile.fromJson(Map<String, dynamic> data) {
    final lastLoginTime = data['Last-Login-Time'];
    final loginFrom = data['Login-From'];
    final loginTime = data['Login-Time'];
    final userAgent = data['User-Agent'];
    final firstName = data['first_name'];
    final lastName = data['last_name'];

    return Profile(
      lastLoginTime: lastLoginTime,
      loginFrom: loginFrom,
      loginTime: loginTime,
      userAgent: userAgent,
      firstName: firstName,
      lastName: lastName,
    );
  }
}

class Token {
  String id;
  String token;
  String type;
  int life;
  String expire;
  String identity;
  String email;
  String createdAt;
  Profile? profile;

  Token({
    required this.id,
    required this.token,
    required this.type,
    required this.life,
    required this.expire,
    required this.identity,
    required this.email,
    required this.createdAt,
    this.profile,
  });

  factory Token.fromJson(Map<String, dynamic> data) {
    if (data['token'] == null ||
        data['token'] == null ||
        data['type'] == null ||
        data['life'] == null ||
        data['expire'] == null ||
        data['identity'] == null ||
        data['email'] == null ||
        data['created_at'] == null) {
      throw Exception('Invalid token');
    }

    final id = data['id'];
    final token = data['token'];
    final type = data['type'];
    final life = data['life'];
    final expire = data['expire'];
    final identity = data['identity'];
    final email = data['email'];
    final createdAt = data['created_at'];
    final profile = Profile.fromJson(data['profile']);

    return Token(
      id: id,
      token: token,
      type: type,
      life: life,
      expire: expire,
      identity: identity,
      email: email,
      createdAt: createdAt,
      profile: profile,
    );
  }

  bool isExpired() {
    try {
      return DateTime.parse(expire)
          .add(const Duration(seconds: -30))
          .isBefore(DateTime.now().toUtc());
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      return true;
    }
  }
}

class Session {
  Token refreshToken;
  Token userToken;

  get currentUser => User.fromSession(this);

  Session({required this.refreshToken, required this.userToken});

  factory Session.fromJson(Map<String, dynamic> data) {
    if (data['refresh_token'] == null || data['active_token'] == null) {
      throw Exception('Invalid session');
    }

    final refreshToken = Token.fromJson(data['refresh_token']);
    final userToken = Token.fromJson(data['active_token']);

    return Session(refreshToken: refreshToken, userToken: userToken);
  }
}
