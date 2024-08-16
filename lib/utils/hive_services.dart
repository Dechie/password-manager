import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

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
