import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pass_mgr/utils/constans.dart';

import '../models/item.dart';

ElevatedButton commonButton({
  required void Function() onPress,
  required String label,
  required double width,
}) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll<Color>(mainRed),
      fixedSize: WidgetStatePropertyAll<Size>(Size(width, 40)),
    ),
    onPressed: onPress,
    child: Text(
      label,
      style: titleStyle1.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

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

String generatePassword() {
  String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String lower = 'abcdefghijklmnopqrstuvwxyz';
  String numbers = '1234567890';
  String symbols = '!@#\$%^&*()<>,./';
  int passLength = 8;
  String seed = upper + lower + numbers + symbols;
  String password = '';
  List<String> list = seed.split('').toList();
  Random rand = Random();

  for (int i = 0; i < passLength; i++) {
    int index = rand.nextInt(list.length);
    password += list[index];
  }
  print("current generated: $password");
  return password;
}
