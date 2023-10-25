import 'package:hive/hive.dart';

class TokenProvider {
  static const _tokenBoxName = 'tokenBox';
  static const _tokenKey = 'token';

  Future<void> openBox() async {
    await Hive.openBox<String>(_tokenBoxName);
  }

  String? get token {
    if (Hive.isBoxOpen(_tokenBoxName)) {
      return Hive.box<String>(_tokenBoxName).get(_tokenKey);
    }
    return null;
  }

  Future<void> setToken(String? token) async {
    final box = await Hive.openBox<String>(_tokenBoxName);
    if(token != null) {
      box.put(_tokenKey, token);
    } else {
      deleteToken();
    }
  }

  Future<void> deleteToken() async {
    if (Hive.isBoxOpen(_tokenBoxName)) {
      final box = Hive.box<String>(_tokenBoxName);
      box.delete(_tokenKey);
    }
  }
}
