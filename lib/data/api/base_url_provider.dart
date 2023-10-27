import 'package:flutter/foundation.dart';

abstract class BaseUrlProvider {
  String get baseUrl;

  Map<String, String> get defaultHeaders =>
      {'Content-Type': 'application/json'};
}

class LocalBaseUrlProvider extends BaseUrlProvider {
  @override
  String get baseUrl =>
      kIsWeb ? 'http://127.0.0.1:8000/' : 'http://10.0.2.2:8000/';
}
