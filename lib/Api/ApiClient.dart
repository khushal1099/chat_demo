import 'dart:convert';
import 'package:chat_demo/Utils/Utils.dart';
import 'package:http/http.dart' as http;

enum ApiMethods { get, post, put, delete }

class ApiClient {
  ApiClient._();

  static String baseUrl = 'https://dummyjson.com/products/';

  static String addProducts = 'add';

  static Future<void> apiCalling(
    String url,
    Function(dynamic body) onResponse, {
    Map<String, String> params = const {},
    ApiMethods apiMethod = ApiMethods.get,
    bool isDebug = false,
  }) async {
    var uri = Uri.parse('$baseUrl$url');

    http.Response? response;

    try {
      if (apiMethod == ApiMethods.get) {
        response = await http.get(uri);
      }
      if (apiMethod == ApiMethods.post) {
        response = await http.post(
          uri,
          body: params,
        );
      }
      if (apiMethod == ApiMethods.put) {
        response = await http.put(
          uri,
          body: params,
        );
      }
      if (apiMethod == ApiMethods.delete) {
        response = await http.delete(
          uri,
          body: params,
        );
      }
    } catch (e) {
      Utils.print('$e', tag: 'Error');
    }
    var data;

    if (response != null) {
      data = jsonDecode(response.body);
      if (isDebug) Utils.print([uri.path, params, data], tag: 'debug');
      onResponse(data);
    } else {
      Utils.print('${response?.statusCode} \n ${response?.body}',
          tag: 'response?.statusCode');
    }

    return data;
  }
}
