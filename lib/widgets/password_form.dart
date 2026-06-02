import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pass_mgr/utils/auth.dart';
import 'package:pass_mgr/utils/constans.dart';

import 'number_button.dart';

class PasswordForm extends StatefulWidget {
  final Size size;
  final String task;

  const PasswordForm({
    super.key,
    required this.size,
    required this.task,
  });

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final TextEditingController _passController = TextEditingController();
  final AuthService auth = AuthService();

  void _onNumberTap(String num) {
    if (_passController.text.length < 6) {
      setState(() {
        _passController.text = "${_passController.text}$num";
      });
    }
  }

  void _onDelete() {
    if (_passController.text.isNotEmpty) {
      setState(() {
        _passController.text =
            _passController.text.substring(0, _passController.text.length - 1);
      });
    }
  }

  Widget _actionKey({required Widget child, required VoidCallback onTap, bool filled = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Material(
          color: filled ? mainDark2 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 1.5,
          shadowColor: Colors.black12,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: filled ? Colors.white24 : mainRed.withAlpha(30),
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinLen = _passController.text.length;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      width: widget.size.width,
      height: widget.size.height * 0.58 + bottomInset,
      decoration: const BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.task,
            style: const TextStyle(
              color: mainDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Enter your PIN to continue",
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final filled = i < pinLen;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? mainRed : Colors.transparent,
                  border: Border.all(
                    color: filled ? mainRed : const Color(0xFFCCCCCC),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Row(children: [
                      NumberButton(number: "1", onPressed: () => _onNumberTap("1")),
                      NumberButton(number: "2", onPressed: () => _onNumberTap("2")),
                      NumberButton(number: "3", onPressed: () => _onNumberTap("3")),
                    ]),
                  ),
                  Expanded(
                    child: Row(children: [
                      NumberButton(number: "4", onPressed: () => _onNumberTap("4")),
                      NumberButton(number: "5", onPressed: () => _onNumberTap("5")),
                      NumberButton(number: "6", onPressed: () => _onNumberTap("6")),
                    ]),
                  ),
                  Expanded(
                    child: Row(children: [
                      NumberButton(number: "7", onPressed: () => _onNumberTap("7")),
                      NumberButton(number: "8", onPressed: () => _onNumberTap("8")),
                      NumberButton(number: "9", onPressed: () => _onNumberTap("9")),
                    ]),
                  ),
                  Expanded(
                    child: Row(children: [
                      _actionKey(
                        onTap: _onDelete,
                        child: const Icon(FontAwesomeIcons.deleteLeft, color: mainDark2, size: 20),
                      ),
                      NumberButton(number: "0", onPressed: () => _onNumberTap("0")),
                      _actionKey(
                        onTap: () async {
                          final ok = await auth.checkPin(_passController.text);
                          if (context.mounted) Navigator.pop(context, ok);
                        },
                        filled: true,
                        child: const Text(
                          "OK",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: bottomInset + 12),
        ],
      ),
    );
  }
}
