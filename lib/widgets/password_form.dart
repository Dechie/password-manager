import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pass_mgr/utils/constans.dart';

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
  String password = "";
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height * .48,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                child: Text(
                  widget.task,
                  style: titleStyle3.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Enter your PIN to perform task",
                  style: titleStyle3,
                ),
              ),
              TextField(
                keyboardType: TextInputType.none,
                controller: _passController,
                decoration: kTextFieldDecoration2.copyWith(
                  hintText: "Input Password",
                  suffix: IconButton(
                    onPressed: () {
                      if (_passController.text.isNotEmpty) {
                        int len = _passController.text.length;
                        _passController.text =
                            _passController.text.substring(0, len - 1);
                      }
                    },
                    icon: const Icon(
                      FontAwesomeIcons.deleteLeft,
                      color: mainDark2,
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
                          _passController.text = "${_passController.text}1";
                        });
                      },
                    ),
                    NumberButton(
                      number: "2",
                      onPressed: () {
                        setState(() {
                          _passController.text = "${_passController.text}2";
                        });
                      },
                    ),
                    NumberButton(
                      number: "3",
                      onPressed: () {
                        setState(() {
                          _passController.text = "${_passController.text}3";
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
                          _passController.text = "${_passController.text}4";
                        });
                      },
                    ),
                    NumberButton(
                      number: "5",
                      onPressed: () {
                        setState(() {
                          _passController.text = "${_passController.text}5";
                        });
                      },
                    ),
                    NumberButton(
                      number: "6",
                      onPressed: () {
                        setState(() {
                          _passController.text = "${_passController.text}6";
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
                          if (_passController.text == "1234") {
                            Navigator.pop(context, true);
                            // authorized
                          } else {
                            Navigator.pop(context, false);
                            // not authorized
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
                                fontSize: 14,
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
  }
}
