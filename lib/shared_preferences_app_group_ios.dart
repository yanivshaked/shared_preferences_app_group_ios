import 'dart:async';

import 'package:flutter/services.dart';

class SharedPreferencesAppGroupIos {
  static const MethodChannel _channel = const MethodChannel('shared_preferences_app_group_ios');

  static const String _prefix = 'flutter.';
  static Map<String, Completer<SharedPreferencesAppGroupIos>> _completersMap;

  SharedPreferencesAppGroupIos._(this._preferenceCache, this._appGroupName);

  /// The cache that holds all preferences.
  ///
  /// It is instantiated to the current state of the SharedPreferences or
  /// NSUserDefaults object and then kept in sync via setter methods in this
  /// class.
  ///
  /// It is NOT guaranteed that this cache and the device prefs will remain
  /// in sync since the setter method might fail for any reason.
  final Map<String, Object> _preferenceCache;

  String _appGroupName;

  /// Returns all keys in the persistent storage.
  Set<String> getKeys() => Set<String>.from(_preferenceCache.keys);

  /// Reads a value of any type from persistent storage.
  dynamic get(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool.
  bool getBool(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int.
  int getInt(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// double.
  double getDouble(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String.
  String getString(String key) => _preferenceCache[key];

  /// Returns true if persistent storage the contains the given [key].
  bool containsKey(String key) => _preferenceCache.containsKey(key);

  /// Reads a set of string values from persistent storage, throwing an
  /// exception if it's not a string set.
  List<String> getStringList(String key) {
    List<Object> list = _preferenceCache[key];
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
      _preferenceCache[key] = list;
    }
    // Make a copy of the list so that later mutations won't propagate
    return list?.toList();
  }

  /// Reads a map of string to string values from persistent storage, throwing an
  /// exception if it's not a string set.
  Map<String, String> getMap(String key) {
    Map<dynamic, dynamic> map = _preferenceCache[key];
    // Make a copy of the list so that later mutations won't propagate
    return map != null ? new Map<String, String>.from(map) : null;
  }

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setBool(String key, bool value) => _setValue('Bool', key, value);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setInt(String key, int value) => _setValue('Int', key, value);

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setDouble(String key, double value) => _setValue('Double', key, value);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setString(String key, String value) => _setValue('String', key, value);

  /// Saves a list of strings [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setStringList(String key, List<String> value) => _setValue('StringList', key, value);

  /// Saves a map [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setMap(String key, Map<String, String> value) => _setValue('Map', key, value);

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) => _setValue(null, key, null);

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() {
    _preferenceCache.clear();
    return _storeClear();
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  Future<void> reload() async {
    final Map<String, Object> preferences = await SharedPreferencesAppGroupIos._getSharedPreferencesMap(_appGroupName);
    _preferenceCache.clear();
    _preferenceCache.addAll(preferences);
  }

  /// Loads and parses the [SharedPreferences] for this app from disk.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  static Future<SharedPreferencesAppGroupIos> getInstance(String appGroupName) async {
    if (_completersMap == null) {
      _completersMap = new Map<String, Completer<SharedPreferencesAppGroupIos>>();
    }

    /* If already exists, use it */
    if (_completersMap.containsKey(appGroupName)) {
      return _completersMap[appGroupName].future;
    }

    /* Does not exist, create one */
    var completer = Completer<SharedPreferencesAppGroupIos>();
    _completersMap[appGroupName] = completer;
    try {
      final Map<String, Object> preferencesMap = await _getSharedPreferencesMap(appGroupName);
      completer.complete(SharedPreferencesAppGroupIos._(preferencesMap, appGroupName));
    } on Exception catch (e) {
      // If there's an error, explicitly return the future with an error.
      // then set the completer to null so we can retry.
      completer.completeError(e);
      final Future<SharedPreferencesAppGroupIos> sharedPrefsFuture = completer.future;
      _completersMap.remove(appGroupName);
      return sharedPrefsFuture;
    }
    return completer.future;
  }

  static Future<Map<String, Object>> _getSharedPreferencesMap(String appGroupName) async {
    final Map<String, Object> fromSystem = await _storeGetAll(appGroupName);
    assert(fromSystem != null);
    // Strip the flutter. prefix from the returned preferences.
    final Map<String, Object> preferencesMap = <String, Object>{};
    for (String key in fromSystem.keys) {
      assert(key.startsWith(_prefix));
      preferencesMap[key.substring(_prefix.length)] = fromSystem[key];
    }
    return preferencesMap;
  }

  Future<bool> _setValue(String valueType, String key, Object value) {
    final String prefixedKey = '$_prefix$key';
    if (value == null) {
      _preferenceCache.remove(key);
      return _storeRemove(prefixedKey);
    } else {
      if (value is List<String>) {
        // Make a copy of the list so that later mutations won't propagate
        _preferenceCache[key] = value.toList();
      } else {
        _preferenceCache[key] = value;
      }
      return _storeSetValue(valueType, prefixedKey, value);
    }
  }

  Future<bool> _storeRemove(String key) {
    return _invokeBoolMethod('remove', <String, dynamic>{
      'appGroupName': _appGroupName,
      'key': key,
    });
  }

  Future<bool> _storeSetValue(String valueType, String key, Object value) {
    return _invokeBoolMethod('set$valueType', <String, dynamic>{
      'appGroupName': _appGroupName,
      'key': key,
      'value': value,
    });
  }

  Future<bool> _invokeBoolMethod(String method, Map<String, dynamic> params) {
    return _channel.invokeMethod<bool>(method, params).then<bool>((dynamic result) => result);
  }

  Future<bool> _storeClear() {
    return _channel.invokeMethod<bool>('clear', <String, dynamic>{
      'appGroupName': _appGroupName,
    });
  }

  static Future<Map<String, Object>> _storeGetAll(String appGroupName) {
    return _channel.invokeMapMethod<String, Object>('getAll', <String, dynamic>{
      'appGroupName': appGroupName,
    });
  }
}
