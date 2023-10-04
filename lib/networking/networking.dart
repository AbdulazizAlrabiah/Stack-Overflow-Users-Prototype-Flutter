import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:stack_overflow_users_prototype_flutter/model/response/error_response.dart';
import 'package:stack_overflow_users_prototype_flutter/networking/api/api_base.dart';
import 'package:stack_overflow_users_prototype_flutter/shared_utilities/shared_logger.dart';

class ResponseObject {
  bool success;
  dynamic data;
  ErrorResponse? error;

  ResponseObject({
    required this.success,
    required this.data,
    required this.error,
  });
}

class Networking {
  static final shared = Networking._();

  Networking._();

  Future<ResponseObject> makeRequest(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    dynamic responseJson;

    var uri = Uri(
        scheme: "https",
        host: APIBase.baseURL,
        path: "/2.2$path",
        queryParameters: params);

    SharedLogger.shared.i("URL: $uri");

    final headers = await _getHeaders();

    try {
      final http.Response response;

      response = await http.get(uri, headers: headers);

      SharedLogger.shared.i(response.body.toString());

      responseJson = json.decode(response.body.toString());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (ResponseObject(
          success: true,
          data: responseJson,
          error: null,
        ));
      } else {
        return (ResponseObject(
          success: false,
          data: null,
          error: ErrorResponse(
            message: "Error, please try again",
            code: null,
          ),
        ));
      }
    } on TimeoutException {
      SharedLogger.shared.d("TimeoutException");
      return (ResponseObject(
        success: false,
        data: null,
        error: ErrorResponse(
          message: "Server Error, please try again",
          code: null,
        ),
      ));
    } on SocketException {
      SharedLogger.shared.d("SocketException");
      return (ResponseObject(
        success: false,
        data: null,
        error: ErrorResponse(
          message: "Error, please connect to the internet",
          code: null,
        ),
      ));
    } on Error catch (error) {
      SharedLogger.shared.d("Error: $error");
      return (ResponseObject(
        success: false,
        data: null,
        error: ErrorResponse(
          message: "Error, please try again",
          code: null,
        ),
      ));
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final Map<String, String> headers = {
      "Accept": "application/json;charset=utf-t",
      "Accept-Language": "en",
    };

    return headers;
  }
}
