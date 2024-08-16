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
  final _form = GlobalKey<FormState>();
  String pin = "";
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: DraggableScrollableSheet(builder: (context, controller) {
            return SizedBox(
              width: size.width,
              height: size.height * .48,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: bgGrey,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Create Your PIN (Up to 6 characters)",
                          style: titleStyle3,
                        ),
                      ),
                      Form(
                        key: _form,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 4 ||
                                value.length > 6) {
                              return "enter proper PIN (4 - 6 digits)";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            pin = value!;
                          },
                          keyboardType: TextInputType.none,
                          controller: _passController,
                          readOnly: true,
                          style: titleStyle3.copyWith(
                            color: mainDark,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: kTextFieldDecoration2.copyWith(
                            hintText: "Input PIN",
                            suffix: IconButton(
                              onPressed: () {
                                if (_passController.text.isNotEmpty) {
                                  int len = _passController.text.length;
                                  _passController.text = _passController.text
                                      .substring(0, len - 1);
                                }
                              },
                              icon: const Icon(
                                FontAwesomeIcons.deleteLeft,
                                color: mainDark2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            NumberButton(
                              number: "1",
                              onPressed: () {
                                setState(() {
                                  _passController.text =
                                      "${_passController.text}1";
                                });
                              },
                            ),
                            NumberButton(
                              number: "2",
                              onPressed: () {
                                setState(() {
                                  _passController.text =
                                      "${_passController.text}2";
                                });
                              },
                            ),
                            NumberButton(
                              number: "3",
                              onPressed: () {
                                setState(() {
                                  _passController.text =
                                      "${_passController.text}3";
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            NumberButton(
                              number: "4",
                              onPressed: () {
                                setState(() {
                                  _passController.text =
                                      "${_passController.text}4";
                                });
                              },
                            ),
                            NumberButton(
                              number: "5",
                              onPressed: () {
                                setState(() {
                                  _passController.text =
                                      "${_passController.text}5";
                                });
                              },
                            ),
                            NumberButton(
                              number: "6",
                              onPressed: () {
                                setState(() {
                                  _passController.text =
                                      "${_passController.text}6";
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        NumberButton(
                                          number: "7",
                                          onPressed: () {
                                            setState(() {
                                              _passController.text =
                                                  "${_passController.text}7";
                                            });
                                          },
                                        ),
                                        NumberButton(
                                          number: "8",
                                          onPressed: () {
                                            setState(() {
                                              _passController.text =
                                                  "${_passController.text}8";
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        NumberButton(
                                          number: "9",
                                          onPressed: () {
                                            setState(() {
                                              _passController.text =
                                                  "${_passController.text}9";
                                            });
                                          },
                                        ),
                                        NumberButton(
                                          number: "0",
                                          onPressed: () {
                                            setState(
                                              () {
                                                _passController.text =
                                                    "${_passController.text}0";
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  if (_form.currentState!.validate()) {
                                    _form.currentState!.save();
                                    AuthService auth = AuthService();
                                    auth.register(pin);
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (ctx) => const HomePage(),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    color: mainDark2,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "OK",
                                      style: titleStyle1.copyWith(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
