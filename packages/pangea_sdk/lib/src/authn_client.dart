// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'types.dart';

const API_VERSION = 'v2';
const USER_STORAGE_KEY = "pangea_user_data";

class AuthNClient {
  ClientConfig config;

  AuthNClient(this.config, {bool useJwt = false});

  /*
    General AuthN functions
  */
  Future<ClientResponse> logout(String userToken) async {
    const path = 'client/session/logout';
    final data = {'token': userToken};
    return await post(path, data);
  }

  Future<ClientResponse> validate(String userToken) async {
    const path = 'client/token/check';
    final payload = {'token': userToken};
    return await post(path, payload);
  }

  Future<ClientResponse> userinfo(String code) async {
    const path = 'client/userinfo';
    final payload = {'code': code};
    return await post(path, payload);
  }

  Future<ClientResponse> refresh(String userToken, String refreshToken) async {
    const path = 'client/session/refresh';
    final payload = {'user_token': userToken, 'refresh_token': refreshToken};
    return await post(path, payload);
  }

  Future<ClientResponse> jwks() async {
    const path = 'client/jwk';
    return await post(path, {});
  }

  Future<ClientResponse> post(String path, Map<String, dynamic> data) async {
    try {
      final Uri url =
          Uri.parse('https://authn.${config.domain}/$API_VERSION/$path');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.clientToken}'
      };

      final response =
          await http.post(url, headers: headers, body: jsonEncode(data));

      final responseBody = jsonDecode(response.body);

      final apiResponse = APIResponse(
          status: responseBody['status'],
          summary: responseBody['summary'],
          result: responseBody['result']);

      return ClientResponse(response: apiResponse, success: true);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return ClientResponse(response: getError(e), success: false);
    }
  }

  APIResponse getError(error) {
    final APIResponse message =
        APIResponse(status: 'Error', summary: '', result: {});

    if (error is http.Response) {
      message.status = error.statusCode.toString();
      message.summary = error.reasonPhrase!;
      message.result = error.body;
    } else {
      message.summary = 'Unhandled error';
      message.result = error;
    }

    return message;
  }
}
