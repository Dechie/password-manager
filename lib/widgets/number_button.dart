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
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 1.5,
          shadowColor: Colors.black12,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            splashColor: mainRed.withAlpha(30),
            highlightColor: mainRed.withAlpha(15),
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                number,
                style: const TextStyle(
                  color: mainDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
