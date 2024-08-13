import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/constans.dart';
import '../utils/functions.dart';

class ItemForm extends StatefulWidget {
  final Size size;

  final void Function(Item item) onAddItem;
  String title;
  String password;
  ItemForm({
    super.key,
    required this.size,
    required this.onAddItem,
    this.title = "",
    this.password = "",
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  bool _generateActivated = false;

  String? generatedPassword;
  String title = "", password = "";
  Item? oldItem;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
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
                          Item aNewItem =
                              Item(title: title, password: password);
                          widget.onAddItem(aNewItem);
                          Navigator.pop(context);
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
                                      _passwordController.text =
                                          generatedPassword!;
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
