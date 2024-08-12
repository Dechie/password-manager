import 'package:flutter/material.dart';

const bgGrey = Color.fromARGB(255, 233, 233, 233);
const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter your password',
  hintStyle: TextStyle(
    color: Colors.grey,
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: mainRed,
      width: 1.0,
    ),
    borderRadius: BorderRadius.all(
      Radius.circular(8.0),
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: mainRed,
      width: 2.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
);

const mainDark = Color.fromARGB(255, 69, 1, 14);
const mainRed = Color.fromARGB(255, 193, 1, 36);
const mainRedAccent = Color.fromARGB(255, 250, 38, 77);
const titleStyle1 = TextStyle(
  color: mainDark,
  fontSize: 16,
  fontWeight: FontWeight.w800,
);

const titleStyle2 = TextStyle(
  color: Colors.white,
  fontSize: 22,
  fontWeight: FontWeight.w700,
);
