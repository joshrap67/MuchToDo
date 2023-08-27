import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:much_todo/src/network/api_result.dart';
import 'package:much_todo/src/repositories/api_request.dart';

class ApiGateway {
  static const String baseUrl = '10.0.2.2:8080';

  static Future<String> getToken() async {
    var token = await FirebaseAuth.instance.currentUser?.getIdToken(); // todo why is this marked as returning null...?
    return token!;
  }

  static Future<ApiResult> post(String route, ApiRequest body) async {
    var url = Uri.http(baseUrl, route);
    var token = await getToken();
    http.Response response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body.toJson()),
    );
    return handleResult(response);
  }

  static Future<ApiResult> put(String route, ApiRequest body) async {
    var url = Uri.http(baseUrl, route);
    var token = await getToken();
    http.Response response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body.toJson()),
    );
    return handleResult(response);
  }

  static Future<ApiResult> delete(String route) async {
    var url = Uri.http(baseUrl, route);
    var token = await getToken();
    http.Response response = await http.delete(url, headers: {"Authorization": "Bearer $token"});
    return handleResult(response);
  }

  static Future<ApiResult> get(String route) async {
    var url = Uri.http(baseUrl, route);
    var token = await getToken();
    http.Response response = await http.get(url, headers: {"Authorization": "Bearer $token"});
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
