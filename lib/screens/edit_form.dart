import 'package:flutter/material.dart';
import 'package:pass_mgr/utils/constans.dart';

import '../models/item.dart';
import '../utils/functions.dart';

class EditForm extends StatefulWidget {
  final Size size;
  final Item oldItem;

  const EditForm({
    super.key,
    required this.size,
    required this.oldItem,
  });

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String title = "", password = "";
  bool _generateActivated = false;
  String? generatedPassword;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height * .6,
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
              TextField(
                  controller: _titleController,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: "Input Title",
                  ),
                  onChanged: (value) {
                    title = value;
                  }),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.number,
                decoration: kTextFieldDecoration.copyWith(
                  hintText: "Input Password",
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              //const Spacer(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: _generateActivated
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceAround,
                children: [
                  if (!_generateActivated)
                    commonButton(
                      width: 140,
                      onPress: () {
                        _generateActivated = true;
                        generatedPassword = generatePassword();
                        setState(() {});
                      },
                      label: "Generate",
                    ),
                  commonButton(
                    width: 100,
                    onPress: () {
                      Item aNewItem = Item(
                        key: widget.oldItem.key,
                        title: title,
                        password: password,
                      );
                      Navigator.pop<Item>(context, aNewItem);
                    },
                    label: "Add",
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (_generateActivated)
                SizedBox(
                  height: 120,
                  width: widget.size.width * .9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: mainRed,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(generatedPassword ?? "Generate Your Password"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            commonButton(
                              onPress: () {
                                setState(() {
                                  generatedPassword = generatePassword();
                                });
                                print(generatedPassword);
                              },
                              label: "Generate New",
                              width: 170,
                            ),
                            commonButton(
                              onPress: () {
                                setState(() {
                                  _passwordController.text = generatedPassword!;
                                  password = generatePassword();
                                  _generateActivated = false;
                                });
                                print("password: $password");
                              },
                              label: "Accept",
                              width: 110,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.oldItem.title;
    _passwordController.text = widget.oldItem.password;
    title = widget.oldItem.title;
    password = widget.oldItem.password;
  }
}
