import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/services/service_interfaces.dart';

class FlutterSecureStorageService implements SecureStorageService {
  FlutterSecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> deleteSecret(String key) => _storage.delete(key: key);

  @override
  Future<String?> readSecret(String key) => _storage.read(key: key);

  @override
  Future<void> writeSecret(String key, String value) =>
      _storage.write(key: key, value: value);
}
