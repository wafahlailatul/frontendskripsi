import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class StorageService {


  static const storage =
      FlutterSecureStorage();



  static Future<void> saveToken(
      String token
  ) async {

    await storage.write(
      key: "token",
      value: token,
    );

  }



  static Future<String?> getToken()
  async {

    return await storage.read(
      key: "token"
    );

  }



  static Future<void> removeToken()
  async {

    await storage.delete(
      key: "token"
    );

  }

}