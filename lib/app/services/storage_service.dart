import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class StorageService {

  // Konfigurasi eksplisit untuk Android agar pakai EncryptedSharedPreferences
  // Ini WAJIB agar token bisa dibaca di release/hosting build
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const storage = FlutterSecureStorage(
    aOptions: _androidOptions,
  );



  static Future<void> saveToken(
      String token
  ) async {

    await storage.write(
      key: "token",
      value: token,
      aOptions: _androidOptions,
    );

  }



  static Future<String?> getToken()
  async {
    return await storage.read(
      key: "token",
      aOptions: _androidOptions,
    );
  }

  static Future<void> saveEmail(String email) async {
    await storage.write(
      key: "email",
      value: email,
      aOptions: _androidOptions,
    );
  }

  static Future<String?> getEmail() async {
    return await storage.read(
      key: "email",
      aOptions: _androidOptions,
    );
  }

  static Future<void> saveProfileImagePath(String path) async {
    await storage.write(
      key: "profile_image",
      value: path,
      aOptions: _androidOptions,
    );
  }

  static Future<String?> getProfileImagePath() async {
    return await storage.read(
      key: "profile_image",
      aOptions: _androidOptions,
    );
  }

  static Future<void> removeToken()
  async {
    await storage.delete(
      key: "token",
      aOptions: _androidOptions,
    );
    await storage.delete(
      key: "email",
      aOptions: _androidOptions,
    );
    await storage.delete(
      key: "profile_image",
      aOptions: _androidOptions,
    );
  }

}