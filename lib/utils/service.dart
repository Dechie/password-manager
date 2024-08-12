// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../models/item.dart';

// class ItemSyncNotifier extends StateNotifier<List<Item>> {
//   ItemSyncNotifier() : super([]);

//   Future<void> syncItemFromServer() async {
//     Dio dio = Dio();
//     Response response;
//     List<Item> temp = [];
//     try {
//       response = await dio.get("http://localhost:8000/api/getItems");

//       if (response.statusCode == 200) {
//         var data = response.data;

//         for (Map<String, dynamic> datum in data) {
//           temp.add(Item.fromJson(datum));
//         }
//         state = [
//           ...temp.where((tmp) => !state.contains(tmp)),
//           ...state,
//         ];
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   Future<void> syncItemsToServer(List<Item> newItems) async {
//     state = [
//       ...newItems.where((test) => !state.contains(test)),
//       ...state,
//     ];

//     Dio dio = Dio();
//     Response response;

//     try {
//       response = await dio.post(
//         "http://localhost:8000/api/uploadItems",
//         data: {
//           "items": jsonEncode(newItems),
//         },
//       );
//       if ([200, 201].contains(response.statusCode)) {
//         print("success");
//       }
//     } catch (e) {
//       e.toString();
//     }
//   }
// }
