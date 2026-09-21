import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageDataSource {
  LocalStorageDataSource({
    required this.sharedPreferences,
  });

  static const databaseVersion = 1;

  @visibleForTesting
  final SharedPreferencesAsync sharedPreferences;

  /// Must be called before the local storage can be used.
  Future<void> init() async {
    final isFirstRun =
        await sharedPreferences.getBool(StorageKey.isFirstRun.name) ?? true;

    if (isFirstRun) {
      await sharedPreferences.setBool(StorageKey.isFirstRun.name, false);
    }

    // the storage version can be used for data migration in the future
    final version = await read(StorageKey.storageVersion) ?? '';
    final currentVersion = int.tryParse(version) ?? 0;
    if (currentVersion > 0 && currentVersion < databaseVersion) {
      // add migration here
    }
    if (currentVersion == 0 || currentVersion < databaseVersion) {
      await write(key: StorageKey.storageVersion, value: '$databaseVersion');
    }
  }

  Future<String?> read(StorageKey key) => sharedPreferences.getString(key.name);

  Future<void> write({required StorageKey key, required String value}) async =>
      sharedPreferences.setString(key.name, value);

  Future<void> delete(StorageKey key) async =>
      sharedPreferences.remove(key.name);

  Future<void> deleteAll() async => sharedPreferences.clear();
}

enum StorageKey { isFirstRun, storageVersion, user, accessToken, refreshToken }
