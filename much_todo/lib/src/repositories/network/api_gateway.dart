import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:much_todo/src/repositories/api_request.dart';
import 'package:much_todo/src/repositories/network/api_result.dart';

class ApiGateway {
  static const String baseUrl = 'us-central1-muchtodo-42777.cloudfunctions.net';
  static const String functionName = '/expressApi';

  static Future<String> getToken({bool forceRefresh = false}) async {
    var token = await FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh);
    return token!;
  }

  static Future<ApiResult> post(String route, ApiRequest body) async {
    var url = Uri.https(baseUrl, '$functionName/$route');
    var token = await getToken();
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body.toJson()),
    );
    return handleResult(response);
  }

  static Future<ApiResult> put(String route, ApiRequest body) async {
    var url = Uri.https(baseUrl, '$functionName/$route');
    var token = await getToken();
    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body.toJson()),
    );
    return handleResult(response);
  }

  static Future<ApiResult> delete(String route) async {
    var url = Uri.https(baseUrl, '$functionName/$route');
    var token = await getToken();
    var response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return handleResult(response);
  }

  static Future<ApiResult> get(String route, {Map<String, String>? queryParams, bool forceTokenRefresh = false}) async {
    var url = Uri.https(baseUrl, '$functionName/$route', queryParams);
    var token = await getToken(forceRefresh: forceTokenRefresh);
    var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    return handleResult(response);
  }

  static ApiResult handleResult(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResult.success(response.body);
    } else {
      return ApiResult.failure(response.body, response.statusCode);
    }
  }
}
