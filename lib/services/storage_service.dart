import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late GetStorage _storage;

  Future<void> init() async {
    await GetStorage.init();
    _storage = GetStorage();
  }

  Future<void> write(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  Future<void> clear() async {
    await _storage.erase();
  }

  bool hasData(String key) {
    return _storage.hasData(key);
  }

  Future<void> saveToken(String token) async {
    print('\n=== STORAGE: SAVE TOKEN ===');
    print('Token: ${token.substring(0, 20)}...');
    await write('auth_token', token);
    print('Token saved successfully');
    print('=== END STORAGE ===\n');
  }

  String? getToken() {
    final token = read<String>('auth_token');
    print('\n=== STORAGE: GET TOKEN ===');
    print('Token: ${token?.substring(0, 20) ?? "null"}');
    print('=== END STORAGE ===\n');
    return token;
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    print('\n=== STORAGE: SAVE USER ===');
    print('User: $user');
    await write('user_data', user);
    print('User saved successfully');
    print('=== END STORAGE ===\n');
  }

  Map<String, dynamic>? getUser() {
    final user = read<Map<String, dynamic>>('user_data');
    print('\n=== STORAGE: GET USER ===');
    print('User: $user');
    print('=== END STORAGE ===\n');
    return user;
  }

  Future<void> clearAuthData() async {
    print('\n=== STORAGE: CLEAR AUTH DATA ===');
    await remove('auth_token');
    await remove('user_data');
    print('Auth data cleared successfully');
    print('=== END STORAGE ===\n');
  }

  Future<void> saveThemeMode(String mode) async {
    await write('theme_mode', mode);
  }

  String? getThemeMode() {
    return read<String>('theme_mode');
  }
}
