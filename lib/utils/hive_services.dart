import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/item.dart';

class HiveServices {
  HiveServices();

  Future<Box> get _box async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    var encryptionKeyString = await secureStorage.read(key: 'hiveKey');
    if (encryptionKeyString == null || encryptionKeyString.isEmpty) {
      throw Exception('Encryption key not found');
    }
    var encryptionKey = base64Url.decode(encryptionKeyString);

    print("at hive_services, key: $encryptionKey");
    Box itemsB = await Hive.openBox(
      "items",
      encryptionCipher: HiveAesCipher(
        encryptionKey,
      ),
    );
    itemsB.put("secret", "secure key");
    return itemsB;
  }

  Future<void> addToHive(Item item) async {
    var box = await _box;
    await box.add(item.toJson());
    print(box.values);
  }

  Future<void> backupHiveData() async {
    var box = await _box;
    var rawData = box.toMap();

    // Convert the data to a JSON-compatible format
    var jsonData = rawData.map((key, value) {
      if (value is Map) {
        // If the value is a nested map, ensure it is JSON-serializable
        return MapEntry(
            key, value.map((k, v) => MapEntry(k.toString(), v.toString())));
      }
      return MapEntry(key.toString(),
          value.toString()); // Convert all other types to strings
    });

    print("rawData: $rawData");
    print("jsonData: $jsonData");

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String backupFilePath = '${appDocDir.path}/hive_backup.json';
    File backupFile = File(backupFilePath);

    await backupFile.writeAsString(jsonEncode(jsonData.toString()));
    print('Backup saved to $backupFilePath');
  }

  Future<void> deleteFromHive(Item item) async {
    var box = await _box;
    await box.delete(item.key);
    print(box.values);
  }

  Future<List<Item>> fetchAll() async {
    var box = await _box;
    print("box opened.");
    final itemsList = [];
    List<Item> myList =
        box.keys.where((key) => key != "secret").toList().map((key) {
      print("item of key: $key");

      final item = box.get(key);

      Map<String, dynamic> mapped = {
        "key": key,
        "title": item["title"],
        "password": item["password"],
      };
      return Item.fromJson(mapped);
    }).toList();
    print(box.values);

    return myList;
  }

  Future<void> updateInHive(Item item) async {
    var box = await _box;
    await box.put(item.key, item.toJson());
    print(box.values);
  }
}
