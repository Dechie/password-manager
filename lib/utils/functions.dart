import 'package:flutter/material.dart';
import 'package:pass_mgr/utils/constans.dart';

import '../models/item.dart';

bool displayRemoveSnackbar(
  BuildContext context,
  Item item,
  String message,
  void Function() callBack,
) {
  bool reInserted = false;
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Text(message),
            const Spacer(),
            TextButton(
              onPressed: () {
                //reInserted = wasInserted;
                callBack();

                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              },
              child: const Text(
                "Undo",
                style: TextStyle(
                  color: mainRedAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        )),
  );
  return reInserted;
}

void displaySnackbar(
  BuildContext context,
  Item item,
  String message,
) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(message),
    ),
  );
}
