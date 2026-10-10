import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over SharedPreferences used by every local data source.
class KeyValueStore {
  final SharedPreferences _p;
  const KeyValueStore(this._p);

  String? getString(String key) => _p.getString(key);
  Future<void> setString(String key, String value) => _p.setString(key, value);

  Object? getJson(String key) {
    final raw = _p.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> setJson(String key, Object value) => _p.setString(key, jsonEncode(value));

  List<String> getStringList(String key) => _p.getStringList(key) ?? const [];
  Future<void> setStringList(String key, List<String> v) => _p.setStringList(key, v);

  Future<void> remove(String key) => _p.remove(key);
}
