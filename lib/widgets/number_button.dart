import 'package:flutter/material.dart';

import '../utils/constans.dart';
class NumberButton extends StatelessWidget {
  final String number;
  final void Function() onPressed;
  const NumberButton({
    super.key,
    required this.number,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: mainDark2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              number,
              style: titleStyle3,
            ),
          ),
        ),
      ),
    );
  }
}