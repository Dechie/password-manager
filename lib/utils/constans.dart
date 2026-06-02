import 'package:flutter/material.dart';

const bgGrey = Color(0xFFF5F5F7);

const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontWeight: FontWeight.w400),
  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFE5E5EA), width: 1.5),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: mainRed, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
);

const kTextFieldDecoration2 = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontWeight: FontWeight.w400),
  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFE5E5EA), width: 1.5),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: mainDark2, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
);

const mainDark = Color(0xFF45010E);
const mainDark2 = Color(0xFF760217);
const mainRed = Color(0xFFC10124);
const mainRedAccent = Color(0xFFFA264D);

const titleStyle1 = TextStyle(
  color: mainDark,
  fontSize: 16,
  fontWeight: FontWeight.w800,
);
const titleStyle2 = TextStyle(
  color: Colors.white,
  fontSize: 22,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.3,
);
const titleStyle3 = TextStyle(
  color: mainDark2,
  fontSize: 16,
  fontWeight: FontWeight.w800,
);
