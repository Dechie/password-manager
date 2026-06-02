import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pass_mgr/screens/home.dart';
import 'package:pass_mgr/utils/auth.dart';
import 'package:pass_mgr/utils/constans.dart';

import '../widgets/number_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _passController = TextEditingController();
  String? _errorText;

  void _onNumberTap(String num) {
    if (_passController.text.length < 6) {
      setState(() {
        _passController.text = "${_passController.text}$num";
        _errorText = null;
      });
    }
  }

  void _onDelete() {
    if (_passController.text.isNotEmpty) {
      setState(() {
        _passController.text =
            _passController.text.substring(0, _passController.text.length - 1);
        _errorText = null;
      });
    }
  }

  void _onOk() {
    final text = _passController.text;
    if (text.length < 4) {
      setState(() => _errorText = "PIN must be at least 4 digits");
      return;
    }
    AuthService auth = AuthService();
    auth.register(text);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (ctx) => const HomePage()),
    );
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
    final size = MediaQuery.of(context).size;
    final pinLen = _passController.text.length;

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: mainRed,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: mainRed.withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  FontAwesomeIcons.shieldHalved,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Password Manager",
                style: TextStyle(
                  color: mainDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create a 4–6 digit PIN to secure your vault",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < pinLen;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 14,
                    height: 14,
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
              AnimatedOpacity(
                opacity: _errorText != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorText ?? "",
                    style: const TextStyle(color: mainRed, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: size.height * 0.38,
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
                          onTap: _onOk,
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
            ],
          ),
        ),
      ),
    );
  }
}
