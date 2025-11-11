import 'dart:html' as html;

/// Web-compatible storage that uses localStorage
/// Works on HTTP (non-secure contexts) unlike flutter_secure_storage
class WebSecureStorage {
  static const String _prefix = 'engreader_';

  /// Write a value to storage
  Future<void> write({required String key, required String value}) async {
    try {
      html.window.localStorage['$_prefix$key'] = value;
      print('WebSecureStorage: Wrote $key');
    } catch (e) {
      print('WebSecureStorage: Error writing $key: $e');
      rethrow;
    }
  }

  /// Read a value from storage
  Future<String?> read({required String key}) async {
    try {
      final value = html.window.localStorage['$_prefix$key'];
      print('WebSecureStorage: Read $key: ${value != null ? "found" : "not found"}');
      return value;
    } catch (e) {
      print('WebSecureStorage: Error reading $key: $e');
      return null;
    }
  }

  /// Delete a value from storage
  Future<void> delete({required String key}) async {
    try {
      html.window.localStorage.remove('$_prefix$key');
      print('WebSecureStorage: Deleted $key');
    } catch (e) {
      print('WebSecureStorage: Error deleting $key: $e');
    }
  }

  /// Delete all values from storage
  Future<void> deleteAll() async {
    try {
      final keys = html.window.localStorage.keys.where((k) => k.startsWith(_prefix)).toList();
      for (final key in keys) {
        html.window.localStorage.remove(key);
      }
      print('WebSecureStorage: Deleted all keys');
    } catch (e) {
      print('WebSecureStorage: Error deleting all: $e');
    }
  }
}
