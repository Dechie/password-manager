import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/item.dart';
import 'crypto_utils.dart';

class HiveServices {
  HiveServices();

  Future<Box> get _box async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final encryptionKeyString = await secureStorage.read(key: 'hiveKey');
    if (encryptionKeyString == null || encryptionKeyString.isEmpty) {
      throw Exception('Encryption key not found');
    }
    final encryptionKey = base64Url.decode(encryptionKeyString);

    return Hive.openBox(
      "items",
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  /// Adds an item and returns its assigned integer key so callers can keep
  /// their in-memory copy in sync (avoids operating on a stale key of -1).
  Future<int> addToHive(Item item) async {
    final box = await _box;
    return await box.add(item.toJson());
  }

  /// Encrypts the full vault with a user-supplied [passphrase] (AES-GCM,
  /// PBKDF2-derived key) and writes it to the app documents directory.
  /// Never writes decrypted secrets to disk.
  Future<String> backupHiveData(String passphrase) async {
    final box = await _box;

    final entries = <Map<String, dynamic>>[];
    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        entries.add({
          'title': value['title'],
          'password': value['password'],
        });
      }
    }

    final plaintext = jsonEncode({'version': 1, 'items': entries});
    final envelope =
        await CryptoUtils.encryptWithPassphrase(plaintext, passphrase);

    final appDocDir = await getApplicationDocumentsDirectory();
    final backupFilePath = '${appDocDir.path}/vault_backup.enc.json';
    await File(backupFilePath).writeAsString(envelope, flush: true);
    return backupFilePath;
  }

  Future<void> deleteFromHive(Item item) async {
    final box = await _box;
    await box.delete(item.key);
  }

  Future<List<Item>> fetchAll() async {
    final box = await _box;
    final result = <Item>[];
    for (final key in box.keys) {
      final item = box.get(key);
      // Skip any legacy non-map entries (e.g. the old "secret" marker).
      if (item is! Map) continue;
      result.add(Item.fromJson({
        "key": key,
        "title": item["title"],
        "password": item["password"],
      }));
    }
    return result;
  }

  Future<void> updateInHive(Item item) async {
    final box = await _box;
    await box.put(item.key, item.toJson());
  }
}
