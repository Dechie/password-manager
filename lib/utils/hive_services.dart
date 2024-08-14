import 'package:hive/hive.dart';

import '../models/item.dart';

class HiveServices {
  HiveServices();

  Future<Box> get _box async => await Hive.openBox("items");

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
    final itemsList = [];
    List<Item> myList = box.keys.map((key) {
      final item = box.get(key);

      Map<String, dynamic> mapped = {
        "key": key,
        "title": item["title"],
        "password": item["password"],
      };
      return Item.fromJson(mapped);
    }).toList();
    print("fetched list type: ${myList.runtimeType}");
    print(box.values);

    return myList;
  }

  Future<void> updateInHive(Item item) async {
    var box = await _box;
    await box.put(item.key, item.toJson());
    print(box.values);
  }
}
